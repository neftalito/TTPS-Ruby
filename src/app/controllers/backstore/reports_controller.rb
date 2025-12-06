module Backstore
  class ReportsController < BaseController
    def index
      @range = params[:range] || "month"

      if @range == "all"
        @start_date = nil
        @end_date   = nil
        @sales_scope = Sale.where(cancelled_at: nil)
      else
        @start_date = params[:start_date].presence ? Date.parse(params[:start_date]) : 1.month.ago.to_date
        @end_date   = params[:end_date].presence ? Date.parse(params[:end_date]) : Date.current

        @start_date, @end_date = @end_date, @start_date if @start_date && @end_date && @start_date > @end_date

        @sales_scope = Sale.where(cancelled_at: nil).where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      end

      # 2. KPIs
      @total_revenue = @sales_scope.sum(:total)
      @total_sales   = @sales_scope.count
      @total_items   = SaleItem.where(sale: @sales_scope).sum(:quantity)
      @average_ticket = @total_sales > 0 ? (@total_revenue / @total_sales) : 0

      ranking_hash = SaleItem.where(sale: @sales_scope).group(:product_id).sum(:quantity)

      sorted_ranking = ranking_hash.sort_by { |_id, qty| -qty }

      per_page = params[:per_page] == "all" ? 1000 : (params[:per_page] || 25).to_i

      @paginated_ranking = Kaminari.paginate_array(sorted_ranking)
                                   .page(params[:page])
                                   .per(per_page)

      current_page_ids = @paginated_ranking.map(&:first)
      products_hash = Product.with_discarded
                             .includes(:category, images_attachments: :blob)
                             .find(current_page_ids)
                             .index_by(&:id)

      @products_for_view = @paginated_ranking.map do |product_id, quantity|
        product = products_hash[product_id]
        if product
          product.define_singleton_method(:total_quantity) { quantity }
          product
        end
      end.compact

      respond_to do |format|
        format.html do
          # Renderiza la vista HTML por defecto
        end

        format.csv do
          send_data generate_csv(@products_for_view), filename: "reporte_ventas_#{Date.today}.csv"
        end

        format.pdf do
          @top_products = @products_for_view

          render pdf: "reporte_ventas_#{Date.today}",
                 layout: "pdf",
                 orientation: "Landscape",
                 encoding: "UTF-8",
                 disposition: "attachment"
        end
      end
    end

    private

    def generate_csv(products)
      bom = "\uFEFF"
      csv_content = CSV.generate(headers: true, encoding: "UTF-8") do |csv|
        csv << ["ID", "Producto", "Artista", "Categoría", "Condición", "Tipo", "Unidades Vendidas"]
        products.each do |product|
          csv << [
            product.id,
            product.name,
            product.author,
            product.category&.name,
            product.condition,
            product.product_type,
            product.total_quantity
          ]
        end
      end
      bom + csv_content
    end
  end
end
