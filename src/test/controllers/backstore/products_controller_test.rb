require "test_helper"

class Backstore::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_products_index_url
    assert_response :success
  end

  test "should get new" do
    get backstore_products_new_url
    assert_response :success
  end

  test "should get edit" do
    get backstore_products_edit_url
    assert_response :success
  end

  test "should get show" do
    get backstore_products_show_url
    assert_response :success
  end
end
