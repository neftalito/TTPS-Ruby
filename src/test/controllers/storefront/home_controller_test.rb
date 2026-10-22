require "test_helper"

class Storefront::HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows the storefront home page" do
    get root_url

    assert_response :success
  end
end
