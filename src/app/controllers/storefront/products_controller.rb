module Storefront
  class ProductsController < BaseController
    before_action :set_product, only: :show

    def index
      @products = available_products
                    .page(params[:page])
                    .per(10)
    end

    def show
    end

    private

    def available_products
      Product
        .where(published: true)
        .includes(:category)
        .order(created_at: :desc)
    end

    def set_product
      @product = available_products.find(params[:id])
    end
  end
end