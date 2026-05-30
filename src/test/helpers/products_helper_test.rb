require "test_helper"

class ProductsHelperTest < ActionView::TestCase
  test "translated_product_type translates normalized values" do
    assert_equal I18n.t("products.types.vinyl"), translated_product_type("vinyl")
    assert_equal "CD", translated_product_type("cd", uppercase: true)
  end
end
