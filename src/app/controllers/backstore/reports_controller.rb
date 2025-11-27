module Backstore
  class ReportsController < BaseController
    def index
      # Guardamos el rango para saber qué botón pintar en la vista
      @range = params[:range] || 'month' 

      # Lógica de fechas
      if @range == 'all'
        @start_date = nil
        @end_date   = nil
        @sales_scope = Sale.where(cancelled_at: nil) # Trae todo sin filtro de fecha
      else
        # Si vienen fechas manuales (custom) o por defecto (month)
        @start_date = params[:start_date].presence ? Date.parse(params[:start_date]) : 1.month.ago.to_date
        @end_date   = params[:end_date].presence ? Date.parse(params[:end_date]) : Date.current
        
        @sales_scope = Sale.where(cancelled_at: nil)
                           .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      end

      # 2. KPIs
      @total_revenue = @sales_scope.sum(:total)
      @total_sales   = @sales_scope.count
      @total_items   = SaleItem.where(sale: @sales_scope).sum(:quantity)
      @average_ticket = @total_sales > 0 ? (@total_revenue / @total_sales) : 0

      per_page = params[:per_page] == "all" ? 1000 : (params[:per_page] || 5).to_i
      @top_products = Product
                        .joins(sale_items: :sale)
                        .where(sales: { id: @sales_scope.select(:id) })
                        .group('products.id')
                        .select('products.*, SUM(sale_items.quantity) as total_quantity')
                        .order('total_quantity DESC')
                        .page(params[:page])
                        .per(per_page)
    end
  end
end