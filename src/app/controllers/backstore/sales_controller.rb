module Backstore
  class SalesController < BaseController
    before_action :set_sale, only: [:show, :cancel]
    def index
      per_page = params[:per_page] == "all" ? Sale.count : (params[:per_page] || 25).to_i
      @sales = Sale.includes(:user).order(created_at: :desc)

      if params[:q].present?
        query = "%#{params[:q].downcase}%"
        @sales = @sales.where("LOWER(buyer_name) LIKE ? OR LOWER(buyer_email) LIKE ?", query, query)
      end

      if params[:status].present?
        case params[:status]
        when "cancelled"
          @sales = @sales.where.not(cancelled_at: nil)
        when "confirmed"
          @sales = @sales.where(cancelled_at: nil)
        end
      end

      @sales = @sales.page(params[:page]).per(per_page)
    end

    def new
      @sale = Sale.new

      @sale.sale_items.build 

      @products = Product.available_products
    end

    def create
      @sale = Sale.new(sale_params)

      @sale.user = current_user 

      if @sale.save

        redirect_to backstore_sale_path(@sale), notice: "Venta registrada exitosamente."
      else

        @products = Product.available_products
        render :new, status: :unprocessable_entity
      end
    end

    def show
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "factura_#{@sale.id}", 
                 template: "backstore/sales/invoice", 
                 layout: "pdf",
                 formats: [:html],
                 disposition: "attachment"
        end
      end
    end

    def cancel


      if @sale.cancel!
        redirect_to backstore_sales_path, notice: "Venta cancelada y stock restaurado."
      else
        redirect_to backstore_sale_path(@sale), alert: "No se pudo cancelar la venta."
      end
    end

    private

    def set_sale
      @sale = Sale.find(params[:id])
    end

    def sale_params
      params.require(:sale).permit(
        :buyer_name, 
        :buyer_email, 
        :buyer_dni,
        sale_items_attributes: [:product_id, :quantity, :_destroy]
      )
    end
  end
end