module NavigationHelper
  # Retorna la clase CSS si la ruta está activa
  def active_link?(path)
    if current_page?(path)
      "bg-proyecto-secondary text-proyecto-primary font-semibold"
    else
      "text-proyecto-bg hover:bg-proyecto-secondary hover:text-proyecto-primary"
    end
  end
end
