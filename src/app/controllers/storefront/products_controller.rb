module Storefront
  class ProductsController < BaseController
    before_action :set_product, only: :show

    def index
      @categories = Category.all
      @products = Product.available_products

      # Búsqueda por Nombre del Disco
      if params[:name_q].present?
        query = "%#{params[:name_q].downcase}%"
        @products = @products.where("LOWER(name) LIKE ?", query)
      end

      # Búsqueda por Nombre del Artista
      if params[:author_q].present?
        query = "%#{params[:author_q].downcase}%"
        @products = @products.where("LOWER(author) LIKE ?", query)
      end

      @products = @products.where(release_year: params[:release_year].to_i) if params[:release_year].present?

      # Filtro por categoría
      @products = @products.where(category_id: params[:category]) if params[:category].present?

      @products = @products.where(product_type: params[:product_type]) if params[:product_type].present?

      @products = @products.where(condition: params[:condition]) if params[:condition].present?

      # Paginación
      @products = @products.page(params[:page]).per(params[:per_page] || 12)
    end

    def show
      @product = Product.available_products.find_by(id: params[:id])
      redirect_to storefront_products_path, alert: "Producto no disponible." unless @product
      @related_products = Product.available_products
                                 .where(category_id: @product.category_id)
                                 .where.not(id: @product.id)
                                 .limit(4)
                                 .order("RANDOM()")
    end

    private

    def available_products
      Product
        .where(published: true)
        .includes(:category)
        .order(created_at: :desc)
    end

    def set_product
      @product = Product.available_products.find_by(id: params[:id])
      redirect_to storefront_products_path, alert: "Producto no disponible." unless @product
    end
  end
end