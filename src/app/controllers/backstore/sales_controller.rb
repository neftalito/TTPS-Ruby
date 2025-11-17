module Backstore
  class SalesController < BaseController
    def index
      @sales = Sale
                 .includes(:user)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(25)
    end

    def new
    end

    def create
    end

    def show
    end

    def cancel
    end
  end
end