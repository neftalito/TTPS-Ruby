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
          send_data generate_csv, filename: "sales_report_#{Date.current}.csv"
        end

        format.pdf do
          render pdf: "sales_report_#{Date.current}",
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
        csv << [I18n.t("backstore.reports.csv.title")]
        csv << [I18n.t("backstore.reports.csv.period"), @report.date_range_label]
        csv << [I18n.t("backstore.reports.csv.product_type"), @report.human_product_type]
        csv << [I18n.t("backstore.reports.csv.genre"), selected_category_name]
        csv << [I18n.t("backstore.reports.csv.employee"), selected_user_name]
        csv << []
        csv << [I18n.t("backstore.reports.csv.metric"), I18n.t("backstore.reports.csv.value")]
        csv << [I18n.t("backstore.reports.index.cards.total_revenue_title"), @total_revenue]
        csv << [I18n.t("backstore.reports.index.cards.total_sales_title"), @total_sales]
        csv << [I18n.t("backstore.reports.index.cards.average_ticket_title"), @average_ticket]
        csv << [I18n.t("backstore.reports.csv.total_products_sold"), @total_items]
        csv << []
        csv << [I18n.t("backstore.reports.csv.sales_by_product_type")]
        csv << [I18n.t("common.labels.type"), I18n.t("backstore.reports.csv.quantity")]
        @sales_by_product_type.each do |label, quantity|
          csv << [label, quantity]
        end
        csv << []
        csv << [I18n.t("backstore.reports.csv.sales_by_genre")]
        csv << [I18n.t("common.labels.genre"), I18n.t("backstore.reports.csv.quantity")]
        @sales_by_genre.each do |genre, quantity|
          csv << [genre, quantity]
        end
        csv << []
        csv << [I18n.t("backstore.reports.index.top_products.title")]
        csv << [
          I18n.t("common.labels.id"),
          I18n.t("common.labels.product"),
          I18n.t("backstore.reports.csv.artist"),
          I18n.t("common.labels.genre"),
          I18n.t("common.labels.type"),
          I18n.t("backstore.reports.csv.units_sold"),
          I18n.t("backstore.reports.csv.revenue")
        ]
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
      return I18n.t("common.options.all") if @report.category_id.blank?

      @selected_category_name ||= Category.find_by(id: @report.category_id)&.name || I18n.t("common.options.all")
    end

    def selected_user_name
      return I18n.t("common.options.all") if @report.user_id.blank?

      @selected_user_name ||= User.find_by(id: @report.user_id)&.email || I18n.t("common.options.all")
    end
  end
end
