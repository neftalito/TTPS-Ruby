module Storefront
  class ProductsController < BaseController
    before_action :set_product, only: :show

    def index
      @categories = Category.all
      @products = Product.available_products
                           .search_by_name(params[:name_q])
                           .search_by_author(params[:author_q])
                           .released_in_year(params[:release_year])
                           .by_category(params[:category])
                           .by_product_type(params[:product_type])
                           .by_condition(params[:condition])

      @products = @products.page(params[:page]).per(params[:per_page] || 12)
    end

    def show
      @product = Product.available_products.find_by(id: params[:id])
      redirect_to storefront_products_path, alert: "Producto no disponible." unless @product
      @related_products = Product.related_to(@product)
    end

    private

    def set_product
      @product = Product.available_products.find_by(id: params[:id])
      redirect_to storefront_products_path, alert: "Producto no disponible." unless @product
    end
  end
end