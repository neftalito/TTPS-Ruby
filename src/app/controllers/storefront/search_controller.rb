module Storefront
  class SearchController < BaseController
    def index
      @query = params[:q].to_s.strip

      scope = Product.search_by_term(@query).with_category_and_attachments

      @products = scope
                  .page(params[:page])
                  .per(25)

      respond_to do |format|
        format.html
        format.any { render :index, formats: :html }
      end
    end
  end
end
