module Backstore
  class SalesReport
    ReportTopProduct = Struct.new(
      :product_id,
      :product_name,
      :product_author,
      :product_type,
      :category_name,
      :total_quantity,
      :total_revenue,
      keyword_init: true
    )

    QUICK_RANGES = %w[today week month year all custom].freeze

    attr_reader :range, :start_date, :end_date, :product_type, :category_id, :user_id

    def initialize(filters = {})
      @range = normalized_range(filters[:range])
      @product_type = normalized_product_type(filters[:product_type])
      @category_id = normalized_integer(filters[:category_id])
      @user_id = normalized_integer(filters[:user_id])
      @start_date, @end_date = resolved_dates(filters[:start_date], filters[:end_date], @range)
    end

    def total_revenue
      @total_revenue ||= sale_items_scope.sum("sale_items.quantity * sale_items.unit_price").to_d
    end

    def total_sales
      @total_sales ||= sale_items_scope.distinct.count(:sale_id)
    end

    def average_ticket
      return 0.to_d if total_sales.zero?

      total_revenue / total_sales
    end

    def total_items
      @total_items ||= sale_items_scope.sum(:quantity)
    end

    def sales_by_product_type
      grouped_quantities_by_product_type.each_with_object({}) do |(type_name, quantity), chart_data|
        chart_data[human_product_type(type_name)] = quantity
      end
    end

    def sales_by_genre
      @sales_by_genre ||= sale_items_scope
                          .group("categories.name")
                          .order(Arel.sql("SUM(sale_items.quantity) DESC"))
                          .sum(:quantity)
    end

    def top_products
      @top_products ||= begin
        rows = sale_items_scope
               .select(
                 "products.id AS product_id",
                 "products.name AS product_name",
                 "products.author AS product_author",
                 "products.product_type AS product_type",
                 "categories.name AS category_name",
                 "SUM(sale_items.quantity) AS total_quantity",
                 "SUM(sale_items.quantity * sale_items.unit_price) AS total_revenue"
               )
               .group("products.id", "products.name", "products.author", "products.product_type", "categories.name")
               .order(Arel.sql("SUM(sale_items.quantity) DESC"), "products.name ASC")
               .limit(5)

        rows.map do |row|
          ReportTopProduct.new(
            product_id: row.product_id,
            product_name: row.product_name,
            product_author: row.product_author,
            product_type: row.product_type,
            category_name: row.category_name,
            total_quantity: row.total_quantity.to_i,
            total_revenue: row.total_revenue.to_d
          )
        end
      end
    end

    def top_products_chart
      top_products.each_with_object({}) do |product, chart_data|
        chart_data["#{product.product_name} - #{product.product_author}"] = product.total_quantity
      end
    end

    def empty?
      total_sales.zero?
    end

    def date_range_label
      return I18n.t("backstore.reports.labels.full_history") if range == "all"
      return I18n.t("backstore.reports.labels.undefined_range") unless start_date && end_date
      return I18n.l(start_date, format: :default) if start_date == end_date

      I18n.t(
        "backstore.reports.labels.range",
        start_date: I18n.l(start_date, format: :default),
        end_date: I18n.l(end_date, format: :default)
      )
    end

    def human_product_type(type_name = product_type)
      case type_name
      when "vinyl"
        I18n.t("products.types.vinyl")
      when "cd"
        I18n.t("products.types.cd")
      else
        I18n.t("common.options.all")
      end
    end

    private

    def sales_scope
      @sales_scope ||= begin
        scope = Sale.confirmed
        scope = scope.between_dates(start_date, end_date) if start_date && end_date
        scope = scope.where(user_id: user_id) if user_id.present?
        scope
      end
    end

    def sale_items_scope
      @sale_items_scope ||= begin
        scope = SaleItem.joins(:sale, product: :category).where(sale_id: sales_scope.select(:id))
        scope = scope.where(products: { product_type: product_type }) if product_type.present?
        scope = scope.where(products: { category_id: category_id }) if category_id.present?
        scope
      end
    end

    def grouped_quantities_by_product_type
      @grouped_quantities_by_product_type ||= sale_items_scope.group("products.product_type").sum(:quantity)
    end

    def normalized_range(raw_range)
      value = raw_range.to_s
      QUICK_RANGES.include?(value) ? value : "month"
    end

    def normalized_product_type(raw_product_type)
      value = raw_product_type.to_s
      Product.product_types.key?(value) ? value : nil
    end

    def normalized_integer(raw_value)
      return nil if raw_value.blank?

      Integer(raw_value, exception: false)
    end

    def parsed_date(raw_date)
      return nil if raw_date.blank?

      Date.parse(raw_date.to_s)
    rescue ArgumentError
      nil
    end

    def resolved_dates(raw_start_date, raw_end_date, selected_range)
      return [nil, nil] if selected_range == "all"

      quick_start_date, quick_end_date = dates_for_range(selected_range)
      start_date = parsed_date(raw_start_date) || quick_start_date
      end_date = parsed_date(raw_end_date) || quick_end_date

      return [start_date, end_date] unless start_date && end_date && start_date > end_date

      [end_date, start_date]
    end

    def dates_for_range(selected_range)
      case selected_range
      when "today"
        [Date.current, Date.current]
      when "week"
        [Date.current.beginning_of_week, Date.current.end_of_week]
      when "year"
        [Date.current.beginning_of_year, Date.current.end_of_year]
      else
        [Date.current.beginning_of_month, Date.current.end_of_month]
      end
    end
  end
end
