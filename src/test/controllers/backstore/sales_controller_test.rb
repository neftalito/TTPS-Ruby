require "test_helper"

class Backstore::SalesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_sales_index_url
    assert_response :success
  end

  test "should get new" do
    get backstore_sales_new_url
    assert_response :success
  end

  test "should get create" do
    get backstore_sales_create_url
    assert_response :success
  end

  test "should get show" do
    get backstore_sales_show_url
    assert_response :success
  end

  test "should get cancel" do
    get backstore_sales_cancel_url
    assert_response :success
  end
end
