module Backstore
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: %i[show edit update destroy change_stock delete_image_attachment]

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

    def create
      @product = Product.new(product_params)
      
      # Asignamos fecha manualmente ya q es un campo personalizado obligatorio
      @product.last_modified_at = Time.current 

      if @product.save
        redirect_to backstore_product_path(@product), notice: 'Producto creado'
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /backstore/products/:id
    def update
      # Separo las imágenes del resto de los parámetros.
      # Uso .except(:images) para que el update no toque las fotos existentes todavía.
      update_params = product_params.except(:images)

      if @product.update(update_params)
        
        #Verifico si el usuario subió fotos nuevas
        if params[:product][:images].present?
          # Las adjunto (append) sin borrar las anteriores
          @product.images.attach(params[:product][:images])
        end

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

    def delete_image_attachment
      # Busco la imagen específica dentro de las adjuntas al producto
      image = @product.images.find(params[:image_id])
      image.purge # .purge elimina el archivo y el registro de la DB
      
      redirect_to edit_backstore_product_path(@product), notice: 'Imagen eliminada correctamente.'
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_backstore_product_path(@product), alert: 'Imagen no encontrada.'
    end

    # PATCH /backstore/products/:id/change_stock
    def change_stock
      stock_param = params.dig(:product, :stock) 
      new_stock_value = stock_param.present? ? stock_param.to_i : nil
      
      if new_stock_value.is_a?(Integer) && new_stock_value >= 0 
        update_attributes = { stock: new_stock_value }
        
        if @product.respond_to?(:last_modified_at) && @product.class.validators_on(:last_modified_at).any?
          update_attributes[:last_modified_at] = Time.current
        end

        if @product.update(update_attributes)
          redirect_to backstore_product_path(@product), notice: 'Stock actualizado correctamente.'
        else
          redirect_to backstore_product_path(@product), alert: "Error al actualizar stock: #{@product.errors.full_messages.join(', ')}"
        end
        
      else
        redirect_to backstore_product_path(@product), alert: "El valor de stock ingresado no es válido."
      end
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      #  Se mantiene images: [] 
      params.require(:product).permit(
        :name, :author, :category_id, :price, :stock,
        :product_type, :product_state, :inventory_entered_at, :description,
        :audio_file, 
        :audio,      # Si es un solo archivo adjunto (has_one_attached) usa :audio (singular)
        images: []   # has_many_attached :images
      )
    end
  end
end