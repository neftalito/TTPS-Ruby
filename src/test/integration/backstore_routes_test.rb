require "test_helper"

class BackstoreRoutesTest < ActionDispatch::IntegrationTest
  test "only implemented backstore routes are exposed" do
    recognized_product = Rails.application.routes.recognize_path("/admin/products/1", method: :get)
    recognized_sale = Rails.application.routes.recognize_path("/admin/sales/1", method: :get)
    recognized_user_edit = Rails.application.routes.recognize_path("/admin/users/1/edit", method: :get)

    assert_equal "backstore/products", recognized_product[:controller]
    assert_equal "show", recognized_product[:action]
    assert_equal "1", recognized_product[:id]

    assert_equal "backstore/sales", recognized_sale[:controller]
    assert_equal "show", recognized_sale[:action]
    assert_equal "1", recognized_sale[:id]

    assert_equal "backstore/users", recognized_user_edit[:controller]
    assert_equal "edit", recognized_user_edit[:action]
    assert_equal "1", recognized_user_edit[:id]

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/categories", method: :get)
    end

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/users/1", method: :get)
    end

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/sales/1/edit", method: :get)
    end
  end
end
