require "test_helper"

class PickupPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pickup_point = pickup_points(:one)
  end

  test "should get index" do
    get pickup_points_url
    assert_response :success
  end

  test "should get new" do
    get new_pickup_point_url
    assert_response :success
  end

  test "should create pickup_point" do
    assert_difference("PickupPoint.count") do
      post pickup_points_url,
           params: { pickup_point: { address: @pickup_point.address, city: @pickup_point.city, enabled: @pickup_point.enabled, name: @pickup_point.name,
                                     province: @pickup_point.province } }
    end

    assert_redirected_to pickup_point_url(PickupPoint.last)
  end

  test "should show pickup_point" do
    get pickup_point_url(@pickup_point)
    assert_response :success
  end

  test "should get edit" do
    get edit_pickup_point_url(@pickup_point)
    assert_response :success
  end

  test "should update pickup_point" do
    patch pickup_point_url(@pickup_point),
          params: { pickup_point: { address: @pickup_point.address, city: @pickup_point.city, enabled: @pickup_point.enabled, name: @pickup_point.name,
                                    province: @pickup_point.province } }
    assert_redirected_to pickup_point_url(@pickup_point)
  end

  test "should destroy pickup_point" do
    assert_difference("PickupPoint.count", -1) do
      delete pickup_point_url(@pickup_point)
    end

    assert_redirected_to pickup_points_url
  end
end
