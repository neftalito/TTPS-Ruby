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

      # 3. Top Products
      @top_products = SaleItem.where(sale: @sales_scope)
                              .group(:product)
                              .order('sum_quantity DESC')
                              .limit(5)
                              .sum(:quantity)
    end
  end
end