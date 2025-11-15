module NavigationHelper
  # Retorna la clase CSS si la ruta está activa
  def active_link?(path)
    current_page?(path) ? "bg-gray-700" : "hover:bg-gray-700"
  end
end
