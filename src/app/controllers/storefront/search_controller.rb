module Storefront
  class SearchController < BaseController
    def index
      @query = params[:q].to_s.strip

      scope = if @query.present?
                sanitized = ActiveRecord::Base.sanitize_sql_like(@query.downcase)

                Product
                  .where(published: true)
                  .includes(:category)
                  .where("LOWER(products.name) LIKE :term OR LOWER(products.description) LIKE :term",
                         term: "%#{sanitized}%")
                  .order(created_at: :desc)
              else
                Product.none
              end

      @products = scope
                    .page(params[:page])
                    .per(25)
    end
  end
end