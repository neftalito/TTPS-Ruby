require "test_helper"

class Backstore::SalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:employee)
    @product = products(:vinyl_rock)
  end

  test "shows the sales index" do
    get backstore_sales_url

    assert_response :success
  end

  test "rejects a sale when the combined quantity exceeds product stock" do
    @product.update_column(:stock, 2)

    assert_no_difference("Sale.count") do
      post backstore_sales_url, params: {
        sale: {
          buyer_name: "Cliente Test",
          buyer_email: "cliente@example.com",
          buyer_dni: "12345678",
          sale_items_attributes: {
            "0" => { product_id: @product.id, quantity: 1 },
            "1" => { product_id: @product.id, quantity: 2 }
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "No hay suficiente stock"
    assert_equal 2, @product.reload.stock
  end
end
