require "test_helper"

class Storefront::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to the catalog when the product does not exist" do
    get storefront_product_url("999999")

    assert_redirected_to storefront_products_url
    assert_equal "Producto no disponible.", flash[:alert]
  end
end
