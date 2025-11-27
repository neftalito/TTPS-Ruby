require "test_helper"

class Storefront::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get storefront_search_index_url
    assert_response :success
  end
end
