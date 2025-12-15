module Storefront
  class SearchController < BaseController
    def index
      @query = params[:q].to_s.strip

      scope = Product.search_by_term(@query)

      @products = scope
                  .page(params[:page])
                  .per(25)
    end
  end
end
