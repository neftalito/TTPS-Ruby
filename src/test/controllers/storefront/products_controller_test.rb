require "test_helper"

class Storefront::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get storefront_products_index_url
    assert_response :success
  end

  test "should get show" do
    get storefront_products_show_url
    assert_response :success
  end
end
