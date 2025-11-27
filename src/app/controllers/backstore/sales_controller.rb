module Backstore
  class SalesController < BaseController
    before_action :set_sale, only: [:show, :cancel]
    def index
      @sales = Sale
                 .includes(:user)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(25)
    end

    def new
      @sale = Sale.new
      # Inicializamos un ítem vacío para que el formulario muestre al menos una línea de producto
      @sale.sale_items.build 
      
      # Cargamos los productos para el select del formulario
      # Usamos el scope 'available_products' que vimos en tu modelo Product
      @products = Product.available_products
    end

    def create
      @sale = Sale.new(sale_params)
      # Asignamos el empleado actual (requisito: "Empleado/a que realizó la venta") [cite: 184]
      @sale.user = current_user 

      if @sale.save
        # Si se guarda, el modelo ya validó stock, descontó cantidades y calculó el total.
        redirect_to backstore_sale_path(@sale), notice: "Venta registrada exitosamente."
      else
        # Si falla (ej: falta stock), volvemos a cargar los productos y mostramos el error.
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
                 formats: [:html]
        end
      end
    end

    def cancel
      # Usamos el método cancel! que creamos en el modelo Sale
      # Esto devuelve el stock automáticamente [cite: 171]
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
        sale_items_attributes: [:product_id, :quantity, :unit_price, :_destroy]
      )
    end
  end
end