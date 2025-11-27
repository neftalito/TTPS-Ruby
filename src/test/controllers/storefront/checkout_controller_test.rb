require "test_helper"

class Storefront::CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get storefront_checkout_index_url
    assert_response :success
  end
end
