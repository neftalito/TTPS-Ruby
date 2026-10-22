require "test_helper"

class Backstore::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:employee)
  end

  test "shows the dashboard" do
    get backstore_root_url

    assert_response :success
    assert_includes response.body, "Panel Administrativo"
  end
end
