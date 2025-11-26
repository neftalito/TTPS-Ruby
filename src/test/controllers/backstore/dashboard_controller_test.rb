require "test_helper"

class Backstore::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_dashboard_index_url
    assert_response :success
  end
end
