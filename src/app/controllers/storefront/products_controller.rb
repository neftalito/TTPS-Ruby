module Storefront
  class ProductsController < BaseController
    before_action :set_product, only: :show

    def index
      @products = Product.kept.page(params[:page]).per(9)
    end

    def show
      @product = Product.kept.find(params[:id])
    end

    private

    def available_products
      Product
        .where(published: true)
        .includes(:category)
        .order(created_at: :desc)
    end

    def set_product
      @product = Product.find_by(id: params[:id], published: true)
      unless @product
        redirect_to storefront_products_path, alert: "Producto no disponible."
      end
    end

  end
end