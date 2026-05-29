require "test_helper"

class Storefront::SearchControllerTest < ActionDispatch::IntegrationTest
  test "shows the search results page" do
    get storefront_search_url, params: { q: "vinilo" }

    assert_response :success
  end
end
