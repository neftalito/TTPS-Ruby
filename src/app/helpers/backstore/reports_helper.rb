module Backstore::ReportsHelper
  def report_quick_range_params(range_name)
    base_filters = request.query_parameters.slice("product_type", "category_id", "user_id").symbolize_keys

    range_filters = case range_name
                    when "today"
                      { range: "today", start_date: Date.current, end_date: Date.current }
                    when "week"
                      { range: "week", start_date: Date.current.beginning_of_week, end_date: Date.current.end_of_week }
                    when "month"
                      { range: "month", start_date: Date.current.beginning_of_month, end_date: Date.current.end_of_month }
                    when "year"
                      { range: "year", start_date: Date.current.beginning_of_year, end_date: Date.current.end_of_year }
                    else
                      { range: "all" }
                    end

    base_filters.merge(range_filters)
  end

  def report_product_type_options
    [
      [I18n.t("common.options.all"), nil],
      [I18n.t("products.types.vinyl"), "vinyl"],
      [I18n.t("products.types.cd"), "cd"]
    ]
  end

  def report_filter_badges(report)
    badges = []
    badges << I18n.t("backstore.reports.badges.period", label: report.date_range_label)
    badges << I18n.t("backstore.reports.badges.type", label: report.human_product_type)

    if report.category_id.present?
      category_name = Category.find_by(id: report.category_id)&.name
      badges << I18n.t("backstore.reports.badges.genre", label: category_name) if category_name.present?
    end

    if report.user_id.present?
      user_name = User.find_by(id: report.user_id)&.email
      badges << I18n.t("backstore.reports.badges.employee", label: user_name) if user_name.present?
    end

    badges
  end
end
