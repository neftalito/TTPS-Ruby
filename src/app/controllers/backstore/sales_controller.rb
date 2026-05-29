module Backstore
  class SalesController < BaseController
    load_and_authorize_resource

    def index
      per_page = params[:per_page] == "all" ? @sales.count : (params[:per_page] || 25).to_i
      @sales = @sales.includes(:user)
                     .ordered_recent
                     .search_by_buyer(params[:q])
                     .with_status(params[:status])

      @sales = @sales.page(params[:page]).per(per_page)
    end

    def show
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "invoice_#{@sale.id}",
                 template: "backstore/sales/invoice",
                 layout: "pdf",
                 formats: [:html],
                 disposition: "attachment"
        end
      end
    end

    def new
      @sale.sale_items.build if @sale.sale_items.empty?
      @products = Product.available_products
    end

    def create
      @sale.user = current_user

      if @sale.save
        redirect_to backstore_sale_path(@sale), notice: I18n.t("flash.backstore.sales.created")
      else
        @products = Product.available_products
        render :new, status: :unprocessable_entity
      end
    end

    def cancel
      if @sale.cancel!
        redirect_to backstore_sales_path, notice: I18n.t("flash.backstore.sales.cancelled")
      else
        redirect_to backstore_sale_path(@sale), alert: I18n.t("flash.backstore.sales.cancel_failed")
      end
    end

    def destroy
      redirect_to backstore_sale_path(@sale), alert: I18n.t("flash.backstore.sales.destroy_forbidden")
    end

    private

    def sale_params
      params.require(:sale).permit(
        :buyer_name,
        :buyer_email,
        :buyer_dni,
        sale_items_attributes: %i[product_id quantity _destroy]
      )
    end
  end
end
