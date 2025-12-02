module Backstore
  class ProductsController < BaseController
    before_action :authenticate_user!
    before_action :set_product, only: %i[show edit update destroy change_stock delete_image_attachment delete_audio_attachment restore]

    def index
      @products = Product.all

      # Filtro por estado (activos, eliminados, todos)
      case params[:status]
      when "deleted"
        @products = @products.only_deleted
      when "all"
        @products = @products.with_deleted
      else
        @products = Product.available_products
      end

      # Filtro por categoría
      if params[:category_id].present?
        @products = @products.where(category_id: params[:category_id])
      end

      # Búsqueda por Nombre del Disco
      if params[:name_q].present?
        query = "%#{params[:name_q].downcase}%"
        @products = @products.where("LOWER(name) LIKE ?", query)
      end

      # Búsqueda por Nombre del Artista
      if params[:author_q].present?
        query = "%#{params[:author_q].downcase}%"
        @products = @products.where("LOWER(author) LIKE ?", query)
      end

      # Filtro por condición
      if params[:condition].present? && params[:condition] != 'all'
        @products = @products.where(condition: params[:condition])
      end
      # Filtro por tipo de producto
      if params[:product_type].present? && params[:product_type] != 'all'
        @products = @products.where(product_type: params[:product_type])
      end

      # Paginación con per_page dinámico
      per_page = params[:per_page] == "all" ? @products.count : (params[:per_page] || 25).to_i
      @products = @products.order(id: :asc).page(params[:page]).per(per_page)
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
      # Clonamos los parámetros para modificar el stock si es necesario
      initial_params = product_params.to_h 
      
      if initial_params['condition'] == 'used'
        initial_params['stock'] = 1
      end

      @product = Product.new(initial_params)
      
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

      # Clonamos los parámetros permitidos para poder modificarlos si es necesario
      permitted_params = product_params.except(:images, :audio)
      
      # Convertimos a hash de Ruby para poder modificar la clave 'stock'
      update_hash = permitted_params.to_h

      if update_hash['condition'] == 'used'
        # Si la condición es 'used', forzamos el stock a 1, ya que el campo estaba deshabilitado 
        update_hash['stock'] = 1
      end

      # Validar límite de imágenes ANTES de intentar actualizar
      if params[:product][:images].present?
        new_images = params[:product][:images].reject(&:blank?)
        new_images_count = new_images.size
        current_images_count = @product.images.count
        total_images = current_images_count + new_images_count
        
        if total_images > 10
          flash.now[:alert] = "No puedes subir #{new_images_count} imagen(es) nueva(s). Ya tienes #{current_images_count} imagen(es) y el límite es 10."
          render :edit, status: :unprocessable_entity
          return
        end
      end

      if @product.update(update_hash)
        
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


    def destroy
      if @product.discard
        redirect_to backstore_products_path, notice: "Producto dado de baja"
      else
        redirect_to backstore_products_path, alert: "No se pudo eliminar el producto"
      end
    end

    def restore
      if @product.undiscard
        redirect_to backstore_products_path, notice: "Producto restaurado correctamente."
      else
        redirect_to backstore_products_path, alert: "No se pudo restaurar el producto."
      end
    end



    def delete_image_attachment
      @product = Product.find(params[:id])
      image = @product.images.find(params[:image_id])

      if @product.images.count <= 1
        redirect_back fallback_location: edit_backstore_product_path(@product),
                      alert: "⚠️ No se puede eliminar la última imagen. Debe quedar al menos una."
        return
      end

      image.purge
      redirect_back fallback_location: edit_backstore_product_path(@product),
                    notice: "Imagen eliminada correctamente."
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
      @product = Product.with_discarded.find(params[:id])
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