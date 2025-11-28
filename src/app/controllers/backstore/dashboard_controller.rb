module Backstore
  class DashboardController < BaseController
    def index
      @sales_chart_data = Sale.where(cancelled_at: nil)
                              .group_by_day(:created_at, range: 1.week.ago..Time.now)
                              .sum(:total)

      @category_chart_data = SaleItem.joins(:product)
                                     .group('products.category_id')
                                     .sum(:quantity)
                                     .transform_keys { |id| Category.find(id).name }

      @low_stock_products = Product.kept.where("stock <= ?", 5).order(:stock).limit(5)

      @recent_sales = Sale.includes(:user).order(created_at: :desc).limit(5)

      @my_sales_count = Sale.where(user: current_user, cancelled_at: nil).count
      @my_total_revenue = Sale.where(user: current_user, cancelled_at: nil).sum(:total)
    end
  end
end