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
end
