module Storefront
  class ProductsController < BaseController
    before_action :set_product, only: :show

    def index
      @categories = Category.all
      @products = Product.available_products

      # Filtro por búsqueda
      if params[:search].present?
        q = "%#{params[:search]}%"
        @products = @products.where("name LIKE :q OR author LIKE :q", q: q)
      end

      # Filtro por categoría
      if params[:category].present?
        @products = @products.where(category_id: params[:category])
      end

      # Paginación
      @products = @products.page(params[:page]).per(params[:per_page] || 12)
    end


    def show
      @product = Product.available_products.find_by(id: params[:id])
      redirect_to storefront_products_path, alert: "Producto no disponible." unless @product
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