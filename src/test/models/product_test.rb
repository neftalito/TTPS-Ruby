require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires at least one image" do
    product = build_product

    assert_not product.valid?
    assert product.errors.of_kind?(:images, :at_least_one_image)
  end

  test "forces stock to one for used products" do
    product = build_product(condition: "used", stock: 7)
    attach_fixture(product.images, "sample.jpg", "image/jpeg")

    assert product.valid?
    assert_equal 1, product.stock
  end

  test "forces stock to one when an existing product changes to used" do
    product = products(:vinyl_rock)
    attach_fixture(product.images, "sample.jpg", "image/jpeg") unless product.images.attached?

    assert product.update(condition: "used", stock: 8, last_modified_at: Time.current)
    assert_equal 1, product.reload.stock
  end

  test "rejects audio for new products" do
    product = build_product(condition: "new")
    attach_fixture(product.images, "sample.jpg", "image/jpeg")
    attach_fixture(product.audio, "sample.mp3", "audio/mpeg")

    assert_not product.valid?
    assert product.errors.of_kind?(:audio, :audio_only_for_used_products)
  end

  test "decrement_stock! updates stock without revalidating unrelated attachments" do
    product = products(:cd_pop)

    product.decrement_stock!(3)

    assert_equal 7, product.reload.stock
  end

  test "increment_stock! caps used products at one" do
    product = products(:vinyl_pop)
    product.update_column(:stock, 0)

    product.increment_stock!(5)

    assert_equal 1, product.reload.stock
  end

  test "human_product_type uses the normalized enum value" do
    product = products(:vinyl_rock)

    assert_equal I18n.t("products.types.vinyl"), product.human_product_type
  end

  test "decrement_stock! rejects negative stock" do
    product = products(:vinyl_pop)

    assert_raises(ArgumentError) do
      product.decrement_stock!(2)
    end
  end

  private

  def build_product(attributes = {})
    Product.new(
      {
        name: "Producto de prueba",
        description: "Descripcion de prueba",
        author: "Autor Test",
        price: 20,
        stock: 5,
        category: categories(:rock),
        published: true,
        product_type: "vinyl",
        condition: "new",
        release_year: 2005,
        last_modified_at: Time.current
      }.merge(attributes)
    )
  end
end
