module ApplicationHelper
  # Devuelve la clase de color de fondo adecuada según el flash
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

  # Devuelve el ícono correspondiente según el flash
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

  # Devuelve el título traducido según el tipo de flash
  def flash_title(type)
    case type.to_sym
    when :notice, :success
      "Éxito"
    when :alert, :error
      "Alerta"
    when :warning
      "Advertencia"
    else
      "Información"
    end
  end

  # Helper: genera modal automáticamente
  def flash_modal
    return unless flash.any?

    type  = flash.keys.first
    msg   = flash[type]

    render partial: "shared/flash_modal",
           locals: { message: msg, flash_type: type }
  end

  def pagination_results_range(collection)
    return "0 de 0" if collection.blank? || !collection.respond_to?(:total_count) || collection.total_count.zero?

    from = collection.offset_value + 1
    to = collection.offset_value + collection.length

    "#{from}-#{to} de #{collection.total_count}"
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
        .merge(page: page, only_path: true)
    )
  end
end