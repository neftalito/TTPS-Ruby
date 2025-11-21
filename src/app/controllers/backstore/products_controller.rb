module Backstore
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: %i[show edit update destroy change_stock]

    # GET /backstore/products
    def index
      @products = Product.available_products.page(params[:page]).per(25)
    end

    # GET /backstore/products/:id
    def show
      # @product cargado por set_product
    end

    # GET /backstore/products/new
    def new
      @product = Product.new
    end

    # GET /backstore/products/:id/edit
    def edit
    end

    # POST /backstore/products
    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to backstore_product_path(@product), notice: 'Producto creado'
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /backstore/products/:id
    def update
      if @product.update(product_params)
        redirect_to backstore_product_path(@product), notice: 'Producto actualizado'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /backstore/products/:id  (borrado lógico)
    def destroy
      @product.soft_delete if @product.respond_to?(:soft_delete)
      redirect_to backstore_products_path, notice: 'Producto dado de baja'
    end

    # PATCH /backstore/products/:id/change_stock
    def change_stock
      # 1. Extraer el valor del stock. params.dig(:product, :stock) devuelve nil o la cadena.
      stock_param = params.dig(:product, :stock) 
      
      # 2. Convertir a entero SOLO si existe, si no, mantenerlo como nil para fallar la validación si es necesario.
      new_stock_value = stock_param.present? ? stock_param.to_i : nil
      
      # 3. Validar y Actualizar
      # Verificamos que sea un número (no nil) y no sea negativo.
      if new_stock_value.is_a?(Integer) && new_stock_value >= 0 
        
        # 4. Actualizar stock y la columna de modificación si es necesaria (prevención de last_modified_at)
        update_attributes = { stock: new_stock_value }
        # Solo incluye last_modified_at si tu modelo lo requiere y no se está actualizando automáticamente
        if @product.respond_to?(:last_modified_at) && @product.class.validators_on(:last_modified_at).any?
          update_attributes[:last_modified_at] = Time.current
        end

        if @product.update(update_attributes)
          redirect_to backstore_product_path(@product), notice: 'Stock actualizado correctamente.'
        else
          redirect_to backstore_product_path(@product), alert: "Error al actualizar stock: #{@product.errors.full_messages.join(', ')}"
        end
        
      else
        # Redirige si el valor enviado no es válido (por ejemplo, nil, vacío o negativo)
        redirect_to backstore_product_path(@product), alert: "El valor de stock ingresado no es válido."
      end
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :author, :category_id, :price, :stock,
        :product_type, :product_state, :inventory_entered_at, :description,
        images: [], audio: []
      )
    end
  end
end