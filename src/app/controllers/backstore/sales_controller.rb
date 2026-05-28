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
          render pdf: "factura_#{@sale.id}",
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
        redirect_to backstore_sale_path(@sale), notice: "Venta registrada exitosamente."
      else
        @products = Product.available_products
        render :new, status: :unprocessable_entity
      end
    end

    def cancel
      if @sale.cancel!
        redirect_to backstore_sales_path, notice: "Venta cancelada y stock restaurado."
      else
        redirect_to backstore_sale_path(@sale), alert: "No se pudo cancelar la venta."
      end
    end

    def destroy
      redirect_to backstore_sale_path(@sale), alert: "Las ventas no se pueden borrar."
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
