require "test_helper"

class Storefront::HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get storefront_home_index_url
    assert_response :success
  end
end
