require "test_helper"

class Backstore::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_users_index_url
    assert_response :success
  end

  test "should get new" do
    get backstore_users_new_url
    assert_response :success
  end

  test "should get edit" do
    get backstore_users_edit_url
    assert_response :success
  end
end
