require "test_helper"

class SaleTest < ActiveSupport::TestCase
  test "calculates total and decrements stock on create" do
    product = products(:vinyl_rock)
    original_stock = product.stock
    sale = build_sale
    sale.sale_items.build(product:, quantity: 2)

    assert sale.save
    assert_equal 40, sale.reload.total.to_i
    assert_equal original_stock - 2, product.reload.stock
  end

  test "requires at least one sale item" do
    sale = build_sale

    assert_not sale.valid?
    assert sale.errors.of_kind?(:base, :at_least_one_sale_item)
  end

  test "requires buyer information" do
    sale = build_sale(buyer_name: "", buyer_email: "", buyer_dni: "")
    sale.sale_items.build(product: products(:vinyl_rock), quantity: 1)

    assert_not sale.valid?
    assert sale.errors.of_kind?(:buyer_name, :blank)
    assert sale.errors.of_kind?(:buyer_email, :blank)
    assert sale.errors.of_kind?(:buyer_dni, :blank)
  end

  test "aggregates repeated products when validating stock" do
    product = products(:vinyl_rock)
    product.update_column(:stock, 2)
    sale = build_sale
    sale.sale_items.build(product:, quantity: 1)
    sale.sale_items.build(product:, quantity: 2)

    assert_not sale.valid?
    assert sale.errors.of_kind?(:base, :insufficient_stock)
    assert_equal 2, product.reload.stock
  end

  test "cancel! restores stock only once" do
    product = products(:cd_pop)
    original_stock = product.stock
    sale = build_sale
    sale.sale_items.build(product:, quantity: 2)
    sale.save!

    sale.cancel!
    stock_after_first_cancel = product.reload.stock
    sale.cancel!

    assert sale.reload.cancelled?
    assert_equal original_stock, stock_after_first_cancel
    assert_equal original_stock, product.reload.stock
  end

  private

  def build_sale(attributes = {})
    Sale.new(
      {
        user: users(:employee),
        buyer_name: "Cliente Test",
        buyer_email: "cliente@example.com",
        buyer_dni: "12345678"
      }.merge(attributes)
    )
  end
end
