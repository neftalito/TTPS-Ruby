module Backstore
  class DashboardController < BaseController
    def index
      @sales_chart_data = Sale.chart_totals_by_day(range: 1.week.ago..Time.current)

      @category_chart_data = SaleItem.category_quantities

      @low_stock_products = Product.low_stock_new

      @recent_sales = Sale.recent_confirmed

      @my_sales_count = Sale.confirmed.for_user(current_user).count
      @my_total_revenue = Sale.total_revenue_for_user(current_user)
    end
  end
end