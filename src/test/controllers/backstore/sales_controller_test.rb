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

  test "shows the sale detail" do
    sale = sales(:recent_employee)

    get backstore_sale_url(sale)

    assert_response :success
    assert_includes response.body, sale.buyer_name
  end

  test "creates a sale and decrements product stock" do
    original_stock = @product.stock

    assert_difference("Sale.count", 1) do
      post backstore_sales_url, params: {
        sale: {
          buyer_name: "Cliente Test",
          buyer_email: "cliente@example.com",
          buyer_dni: "12345678",
          sale_items_attributes: {
            "0" => { product_id: @product.id, quantity: 2 }
          }
        }
      }
    end

    sale = Sale.order(:id).last

    assert_redirected_to backstore_sale_url(sale)
    assert_equal users(:employee).id, sale.user_id
    assert_equal 40, sale.total.to_i
    assert_equal original_stock - 2, @product.reload.stock
  end

  test "cancels a sale and restores product stock" do
    original_stock = @product.stock
    sale = Sale.create!(
      user: users(:employee),
      buyer_name: "Cliente Cancelacion",
      buyer_email: "cancelacion@example.com",
      buyer_dni: "87654321",
      sale_items_attributes: {
        "0" => { product_id: @product.id, quantity: 2 }
      }
    )

    assert_equal original_stock - 2, @product.reload.stock

    patch cancel_backstore_sale_url(sale)

    assert_redirected_to backstore_sales_url
    assert sale.reload.cancelled?
    assert_equal original_stock, @product.reload.stock
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

  test "rejects a sale with missing buyer information" do
    assert_no_difference("Sale.count") do
      post backstore_sales_url, params: {
        sale: {
          buyer_name: "",
          buyer_email: "",
          buyer_dni: "",
          sale_items_attributes: {
            "0" => { product_id: @product.id, quantity: 1 }
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal @product.stock, @product.reload.stock
  end

  test "does not allow destroying a sale" do
    sale = sales(:recent_employee)

    assert_no_difference("Sale.count") do
      delete backstore_sale_url(sale)
    end

    assert_redirected_to backstore_sale_url(sale)
    assert_not sale.reload.cancelled?
  end
end
