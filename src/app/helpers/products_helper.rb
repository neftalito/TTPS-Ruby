module ProductsHelper
  def product_cover_thumbnail(product, size: 48, wrapper_class: "")
    classes = [
      "overflow-hidden rounded-md border border-proyecto-text/10 bg-proyecto-secondary/20 flex items-center justify-center",
      wrapper_class
    ].join(" ").strip

    style = "width: #{size}px; height: #{size}px;"

    if product&.images&.attached?
      image = product.images.first

      content_tag(
        :div,
        image_tag(image, class: "h-full w-full object-cover", alt: product.name),
        class: classes,
        style:
      )
    else
      content_tag(
        :div,
        content_tag(:span, I18n.t("common.states.no_image_short"), class: "text-[10px] text-proyecto-text/40"),
        class: classes,
        style:
      )
    end
  end

  def translated_product_type(type, uppercase: false)
    normalized = type.to_s.strip.downcase
    normalized = "vinyl" if normalized == "viniyl"

    label = I18n.t("products.types.#{normalized}", default: normalized.present? ? normalized.humanize : I18n.t("products.types.all"))
    uppercase ? label.upcase : label
  end

  def translated_product_condition(condition, uppercase: false)
    normalized = condition.to_s.strip.downcase
    label = I18n.t("products.conditions.#{normalized}", default: normalized.humanize)

    uppercase ? label.upcase : label
  end
end
