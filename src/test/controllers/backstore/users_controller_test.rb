require "test_helper"

class Backstore::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
  end

  test "shows the users index" do
    get backstore_users_url

    assert_response :success
  end

  test "shows the edit page for an existing user" do
    get edit_backstore_user_url(users(:employee))

    assert_response :success
  end
end
