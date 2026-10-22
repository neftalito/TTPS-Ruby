require "test_helper"

class SaleItemTest < ActiveSupport::TestCase
  test "category quantities exclude cancelled sales by default" do
    assert_equal({ "Rock" => 3, "Pop" => 3 }, SaleItem.category_quantities)
  end

  test "category quantities can use an explicit sales scope" do
    assert_equal({ "Rock" => 3, "Pop" => 6 }, SaleItem.category_quantities(Sale.all))
  end
end
