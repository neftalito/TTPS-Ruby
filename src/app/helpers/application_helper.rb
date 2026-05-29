module ApplicationHelper
  # Devuelve la clase de color de fondo adecuada segun el flash
  def flash_color(type)
    case type.to_sym
    when :notice, :success
      "bg-proyecto-success"
    when :alert, :error
      "bg-proyecto-error"
    when :warning
      "bg-proyecto-warning"
    else
      "bg-proyecto-info"
    end
  end

  # Devuelve el icono correspondiente segun el flash
  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      "fa-check-circle"
    when :alert, :error
      "fa-times-circle"
    when :warning
      "fa-exclamation-triangle"
    else
      "fa-info-circle"
    end
  end

  # Devuelve el titulo traducido segun el tipo de flash
  def flash_title(type)
    key = case type.to_sym
          when :notice, :success
            :success
          when :alert, :error
            :alert
          when :warning
            :warning
          else
            :info
          end

    I18n.t("common.flash_titles.#{key}")
  end

  # Helper: genera modal automaticamente
  def flash_modal
    return unless flash.any?

    type  = flash.keys.first
    msg   = flash[type]

    render partial: "shared/flash_modal",
           locals: { message: msg, flash_type: type }
  end

  def pagination_results_range(collection)
    return I18n.t("common.pagination.empty_range") if collection.blank? || !collection.respond_to?(:total_count) ||
                                                       collection.total_count.zero?

    from = collection.offset_value + 1
    to = collection.offset_value + collection.length

    I18n.t("common.pagination.range", from:, to:, total: collection.total_count)
  end

  def frontend_translations_json
    json_escape(
      {
        customConfirm: {
          title: I18n.t("javascript.custom_confirm.title"),
          cancel: I18n.t("common.actions.cancel"),
          accept: I18n.t("common.actions.accept")
        }
      }.to_json
    )
  end

  def locale_switch_target
    I18n.locale.to_s == "es" ? "en" : "es"
  end

  def locale_switch_label(locale = locale_switch_target)
    I18n.t("common.locales.#{locale}")
  end

  def locale_switch_aria_label
    I18n.t("common.navigation.change_language_to", language: locale_switch_label)
  end

  def pagination_button(label, page, collection, disabled: false)
    disabled ||= page.nil? || collection.nil?
    base_classes = "px-3 py-1 rounded-md text-sm font-medium transition"

    if disabled
      content_tag(:span,
                  label,
                  class: [
                    base_classes,
                    "bg-proyecto-secondary/20 text-proyecto-secondary/60 cursor-not-allowed"
                  ].join(" "))
    else
      link_to label,
              pagination_url_for_page(page),
              class: [
                base_classes,
                "bg-proyecto-primary text-proyecto-bg hover:bg-proyecto-accent"
              ].join(" ")
    end
  end

  private

  def pagination_url_for_page(page)
    url_for(
      request
        .path_parameters
        .merge(request.query_parameters)
        .merge(page:, only_path: true)
    )
  end
end
