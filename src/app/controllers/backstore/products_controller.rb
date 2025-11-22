module Backstore
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: %i[show edit update destroy change_stock delete_image_attachment delete_audio_attachment]

    # GET /backstore/products
    def index
      @products = Product.available_products.page(params[:page]).per(25)
    end

    # GET /backstore/products/:id
    def show
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
      # Guardamos el estado anterior para comparar
      previous_condition = @product.condition
      
      # Actualizamos los parámetros excepto las imágenes y el audio
      update_params = product_params.except(:images, :audio)

      if @product.update(update_params)
        
        # Si cambió de usado a nuevo, eliminamos el audio existente
        if previous_condition == "used" && @product.condition == "new" && @product.audio.attached?
          @product.audio.purge
        end

        # Si es usado y hay un nuevo archivo de audio, lo adjuntamos
        if @product.condition == "used" && params[:product][:audio].present?
          @product.audio.attach(params[:product][:audio])
        end

        # Si hay nuevas imágenes, las adjuntamos
        if params[:product][:images].present?
          @product.images.attach(params[:product][:images])
        end

        redirect_to backstore_product_path(@product), notice: 'Producto actualizado'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /backstore/products/:id (borrado lógico)
    def destroy
      @product.soft_delete if @product.respond_to?(:soft_delete)
      redirect_to backstore_products_path, notice: 'Producto dado de baja'
    end

    # DELETE /backstore/products/:id/delete_image_attachment
    def delete_image_attachment
      image = @product.images.find(params[:image_id])
      image.purge
      
      redirect_to edit_backstore_product_path(@product), notice: 'Imagen eliminada correctamente.'
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_backstore_product_path(@product), alert: 'Imagen no encontrada.'
    end

    # DELETE /backstore/products/:id/delete_audio_attachment
    def delete_audio_attachment
      if @product.audio.attached?
        @product.audio.purge
        redirect_to edit_backstore_product_path(@product), notice: 'Audio eliminado correctamente.'
      else
        redirect_to edit_backstore_product_path(@product), alert: 'No hay audio para eliminar.'
      end
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
      params.require(:product).permit(
        :name, :author, :category_id, :price, :stock,
        :product_type, :condition, :inventory_entered_at, :description,
        :audio,
        images: []
      )
    end
  end
end