module Backstore
  class ReportsController < BaseController
    before_action :authorize_sales_access!
    before_action :build_report

    def index
      @range = @report.range
      @start_date = @report.start_date
      @end_date = @report.end_date

      @total_revenue = @report.total_revenue
      @total_sales = @report.total_sales
      @total_items = @report.total_items
      @average_ticket = @report.average_ticket
      @sales_by_product_type = @report.sales_by_product_type
      @sales_by_genre = @report.sales_by_genre
      @top_products = @report.top_products
      @top_products_chart = @report.top_products_chart
      @top_product_records = Product.with_discarded
                                    .with_category_and_attachments
                                    .where(id: @top_products.map(&:product_id))
                                    .index_by(&:id)

      @filter_categories = Category.order(:name)
      @filter_users = User.order(:email)
      @export_params = report_filters.to_h.compact_blank.except("page")

      respond_to do |format|
        format.html

        format.csv do
          send_data generate_csv, filename: "reporte_ventas_#{Date.current}.csv"
        end

        format.pdf do
          render pdf: "reporte_ventas_#{Date.current}",
                 layout: "pdf",
                 orientation: "Landscape",
                 encoding: "UTF-8",
                 disposition: "attachment"
        end
      end
    end

    private

    def authorize_sales_access!
      authorize! :read, Sale
    end

    def build_report
      @report = Backstore::SalesReport.new(report_filters)
    end

    def report_filters
      params.permit(:range, :start_date, :end_date, :product_type, :category_id, :user_id)
    end

    def generate_csv
      bom = "\uFEFF"
      csv_content = CSV.generate(headers: true, encoding: "UTF-8") do |csv|
        csv << ["Reporte de ventas"]
        csv << ["Periodo", @report.date_range_label]
        csv << ["Tipo de producto", @report.human_product_type]
        csv << ["Genero", selected_category_name]
        csv << ["Empleado", selected_user_name]
        csv << []
        csv << ["Metrica", "Valor"]
        csv << ["Total recaudado", @total_revenue]
        csv << ["Cantidad de ventas", @total_sales]
        csv << ["Promedio por venta", @average_ticket]
        csv << ["Cantidad de productos vendidos", @total_items]
        csv << []
        csv << ["Ventas por tipo de producto"]
        csv << ["Tipo", "Cantidad"]
        @sales_by_product_type.each do |label, quantity|
          csv << [label, quantity]
        end
        csv << []
        csv << ["Ventas por genero"]
        csv << ["Genero", "Cantidad"]
        @sales_by_genre.each do |genre, quantity|
          csv << [genre, quantity]
        end
        csv << []
        csv << ["Top 5 productos mas vendidos"]
        csv << ["ID", "Producto", "Artista", "Genero", "Tipo", "Unidades Vendidas", "Recaudacion"]
        @top_products.each do |product|
          csv << [
            product.product_id,
            product.product_name,
            product.product_author,
            product.category_name,
            @report.human_product_type(product.product_type),
            product.total_quantity,
            product.total_revenue
          ]
        end
      end

      bom + csv_content
    end

    def selected_category_name
      return "Todos" if @report.category_id.blank?

      @selected_category_name ||= Category.find_by(id: @report.category_id)&.name || "Todos"
    end

    def selected_user_name
      return "Todos" if @report.user_id.blank?

      @selected_user_name ||= User.find_by(id: @report.user_id)&.email || "Todos"
    end
  end
end
