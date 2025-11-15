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
end