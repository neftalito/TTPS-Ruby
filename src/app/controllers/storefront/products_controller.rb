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

      per_page = sanitized_per_page(
        params[:per_page],
        default: DEFAULT_STOREFRONT_PER_PAGE,
        max: MAX_STOREFRONT_PER_PAGE
      )
      @products = @products.page(params[:page]).per(per_page)
    end

    def show
      @related_products = Product.related_to(@product)
    end

    private

    def set_product
      @product = Product.available_products.find_by(id: params[:id])
      return if @product

      redirect_to storefront_products_path, alert: I18n.t("flash.storefront.products.unavailable")
    end
  end
end
