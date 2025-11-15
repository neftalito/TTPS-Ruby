require "test_helper"

class Storefront::CartControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get storefront_cart_show_url
    assert_response :success
  end
end
