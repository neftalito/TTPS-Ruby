require "test_helper"

class Backstore::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:employee)
    @product = products(:vinyl_rock)
    attach_fixture(@product.images, "sample.jpg", "image/jpeg") unless @product.images.attached?
  end

  test "shows the products index" do
    get backstore_products_url

    assert_response :success
  end

  test "creates a product with an uploaded image" do
    assert_difference("Product.count", 1) do
      post backstore_products_url, params: { product: new_product_params }
    end

    product = Product.order(:id).last

    assert_redirected_to backstore_product_url(product)
    assert_equal "Nuevo Lanzamiento", product.name
    assert product.images.attached?
  end

  test "updates product attributes and attaches a new image" do
    initial_image_count = @product.images.attachments.count

    patch backstore_product_url(@product), params: {
      product: valid_product_params(@product).merge(
        name: "Nombre actualizado",
        images: [upload_fixture("sample.jpg", "image/jpeg")]
      )
    }

    assert_redirected_to backstore_product_url(@product)
    assert_equal "Nombre actualizado", @product.reload.name
    assert_equal initial_image_count + 1, @product.images.attachments.count
  end

  test "deletes an image attachment when more than one image is present" do
    attach_fixture(@product.images, "sample.jpg", "image/jpeg") if @product.images.attachments.count < 2
    initial_image_count = @product.images.attachments.count
    image_attachment = @product.images.attachments.last

    delete delete_image_attachment_backstore_product_url(@product, image_id: image_attachment.id)

    assert_redirected_to edit_backstore_product_url(@product)
    assert_equal initial_image_count - 1, @product.reload.images.attachments.count
  end

  test "does not delete the last remaining image attachment" do
    @product.images.attachments.drop(1).each(&:purge)
    image_attachment = @product.images.attachments.first

    delete delete_image_attachment_backstore_product_url(@product, image_id: image_attachment.id)

    assert_redirected_to edit_backstore_product_url(@product)
    assert_equal 1, @product.reload.images.attachments.count
  end

  test "soft deletes a product" do
    delete backstore_product_url(@product)

    deleted_product = Product.find(@product.id)

    assert_redirected_to backstore_products_url
    assert deleted_product.deleted?
    assert_equal 0, deleted_product.stock
  end

  test "restores a deleted product" do
    @product.discard

    patch restore_backstore_product_url(@product)

    restored_product = Product.find(@product.id)

    assert_redirected_to backstore_products_url
    assert_not restored_product.deleted?
  end

  test "keeps product changes atomic when new attachments are invalid" do
    original_name = @product.name

    patch backstore_product_url(@product), params: {
      product: valid_product_params(@product).merge(
        name: "Nombre actualizado",
        images: [upload_fixture("not_an_image.txt", "text/plain")]
      )
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @product.reload.name
    assert_equal 1, @product.images.attachments.count
  end

  test "keeps persisted media visible when update rolls back" do
    product = products(:vinyl_pop)
    product.update_column(:stock, 1)
    attach_fixture(product.images, "sample.jpg", "image/jpeg") unless product.images.attached?
    attach_fixture(product.audio, "sample.mp3", "audio/mpeg") unless product.audio.attached?
    persisted_image_links = product.images.attachments.count

    patch backstore_product_url(product), params: {
      product: valid_product_params(product).merge(
        name: "",
        condition: "new",
        images: [upload_fixture("sample.jpg", "image/jpeg")]
      )
    }

    assert_response :unprocessable_entity
    assert product.reload.audio.attached?
    assert_equal persisted_image_links, product.images.attachments.count
    assert_includes response.body, delete_audio_attachment_backstore_product_path(product)
    assert_equal persisted_image_links, response.body.scan(%r{/delete_image_attachment\?image_id=}).count
  end

  test "purges existing audio after successfully changing a product to new" do
    product = products(:vinyl_pop)
    product.update_column(:stock, 1)
    attach_fixture(product.images, "sample.jpg", "image/jpeg") unless product.images.attached?
    attach_fixture(product.audio, "sample.mp3", "audio/mpeg") unless product.audio.attached?
    original_audio_blob_id = product.audio.blob.id
    original_audio_attachment_id = product.audio.attachment.id

    patch backstore_product_url(product), params: {
      product: valid_product_params(product).merge(
        condition: "new",
        stock: 4
      )
    }

    assert_redirected_to backstore_product_url(product)
    assert_not product.reload.audio.attached?
    assert_not ActiveStorage::Attachment.exists?(original_audio_attachment_id)
    assert_not ActiveStorage::Blob.exists?(original_audio_blob_id)
  end

  test "deletes an attached audio file" do
    product = products(:vinyl_pop)
    attach_fixture(product.images, "sample.jpg", "image/jpeg") unless product.images.attached?
    attach_fixture(product.audio, "sample.mp3", "audio/mpeg") unless product.audio.attached?
    original_audio_blob_id = product.audio.blob.id
    original_audio_attachment_id = product.audio.attachment.id

    delete delete_audio_attachment_backstore_product_url(product)

    assert_redirected_to edit_backstore_product_url(product)
    assert_not product.reload.audio.attached?
    assert_not ActiveStorage::Attachment.exists?(original_audio_attachment_id)
    assert_not ActiveStorage::Blob.exists?(original_audio_blob_id)
  end

  test "changes stock with a valid value" do
    patch change_stock_backstore_product_url(@product), params: {
      product: { stock: 4 }
    }

    assert_redirected_to backstore_product_url(@product)
    assert_equal 4, @product.reload.stock
  end

  test "rejects invalid stock changes for used products" do
    product = products(:vinyl_pop)
    attach_fixture(product.images, "sample.jpg", "image/jpeg") unless product.images.attached?

    patch change_stock_backstore_product_url(product), params: {
      product: { stock: 2 }
    }

    assert_redirected_to backstore_product_url(product)
    assert_equal 1, product.reload.stock
  end

  private

  def valid_product_params(product)
    {
      name: product.name,
      description: product.description,
      author: product.author,
      price: product.price,
      stock: product.stock,
      category_id: product.category_id,
      product_type: product.product_type,
      condition: product.condition,
      release_year: product.release_year
    }
  end

  def new_product_params
    {
      name: "Nuevo Lanzamiento",
      description: "Disco nuevo para testing",
      author: "Banda Test",
      price: 30.0,
      stock: 5,
      category_id: categories(:rock).id,
      product_type: "vinyl",
      condition: "new",
      release_year: 2010,
      images: [upload_fixture("sample.jpg", "image/jpeg")]
    }
  end
end
