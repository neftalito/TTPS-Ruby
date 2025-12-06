require "test_helper"

class Backstore::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_reports_index_url
    assert_response :success
  end
end
