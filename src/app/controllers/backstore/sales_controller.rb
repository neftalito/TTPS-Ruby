module Backstore
  class SalesController < BaseController
    before_action :authorize_sale_collection!, only: %i[index new create]
    before_action :set_sale, only: %i[show cancel]
    before_action -> { authorize! :read, @sale }, only: :show
    before_action -> { authorize! :update, @sale }, only: :cancel

    def index
      per_page = params[:per_page] == "all" ? Sale.count : (params[:per_page] || 25).to_i
      @sales = Sale.accessible_by(current_ability).includes(:user).order(created_at: :desc)

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
      authorize! :create, Sale
      @sale = Sale.new

      @sale.sale_items.build

      @products = Product.available_products
    end

    def create
      authorize! :create, Sale
      @sale = Sale.new(sale_params)

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

    private

    def authorize_sale_collection!
      required_permission = action_name.in?(%w[new create]) ? :create : :read
      authorize! required_permission, Sale
    end

    def set_sale
      @sale = Sale.accessible_by(current_ability).find(params[:id])
    end

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