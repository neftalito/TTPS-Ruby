require "test_helper"

module Backstore
  class SalesReportTest < ActiveSupport::TestCase
    test "calculates metrics excluding cancelled sales" do
      report = SalesReport.new(
        range: "custom",
        start_date: "2026-05-01",
        end_date: "2026-05-31"
      )

      assert_equal 125, report.total_revenue.to_i
      assert_equal 2, report.total_sales
      assert_equal 6, report.total_items
      assert_equal 62, report.average_ticket.to_i
      assert_equal({ "Vinilo" => 5, "CD" => 1 }, report.sales_by_product_type)
      assert_equal({ "Rock" => 3, "Pop" => 3 }, report.sales_by_genre)
      assert_equal ["Vinilo Rojo", "Vinilo Dorado", "CD Azul"], report.top_products.map(&:product_name)
    end

    test "filters the report by product type" do
      report = SalesReport.new(
        range: "custom",
        start_date: "2026-05-01",
        end_date: "2026-05-31",
        product_type: "cd"
      )

      assert_equal 15, report.total_revenue.to_i
      assert_equal 1, report.total_sales
      assert_equal 1, report.total_items
      assert_equal({ "CD" => 1 }, report.sales_by_product_type)
      assert_equal ["CD Azul"], report.top_products.map(&:product_name)
    end

    test "filters the report by employee" do
      report = SalesReport.new(
        range: "custom",
        start_date: "2026-05-01",
        end_date: "2026-05-31",
        user_id: users(:employee).id
      )

      assert_equal 55, report.total_revenue.to_i
      assert_equal 1, report.total_sales
      assert_equal 3, report.total_items
      assert_equal({ "Vinilo" => 2, "CD" => 1 }, report.sales_by_product_type)
    end
  end
end
