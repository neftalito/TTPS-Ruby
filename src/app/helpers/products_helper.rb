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
        style: style
      )
    else
      content_tag(
        :div,
        content_tag(:span, "Sin img", class: "text-[10px] text-proyecto-text/40"),
        class: classes,
        style: style
      )
    end
  end
end
