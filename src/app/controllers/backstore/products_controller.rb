module Backstore
  class ProductsController < BaseController
    load_and_authorize_resource

    def index
      @products = @products.with_discarded
      @products = @products.with_status(params[:status])
      @products = @products.by_category(params[:category_id])
      @products = @products.search_by_name(params[:name_q])
      @products = @products.search_by_author(params[:author_q])
      @products = @products.by_condition(params[:condition])
      @products = @products.by_product_type(params[:product_type])

      per_page = params[:per_page] == "all" ? @products.count : (params[:per_page] || 25).to_i
      @products = @products.order(id: :asc).page(params[:page]).per(per_page)
    end

    def show; end

    def new; end

    def edit; end

    def create
      @product.stock = 1 if @product.condition == "used"
      @product.last_modified_at = Time.current

      if @product.save
        redirect_to backstore_product_path(@product), notice: "Producto creado"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      previous_condition = @product.condition
      permitted_params = product_params.except(:images, :audio)
      update_hash = permitted_params.to_h

      update_hash["stock"] = 1 if update_hash["condition"] == "used"

      if params[:product][:images].present?
        new_images = params[:product][:images].reject(&:blank?)
        new_images_count = new_images.size
        current_images_count = @product.images.count
        total_images = current_images_count + new_images_count

        if total_images > 10
          flash.now[:alert] =
            "No puedes subir #{new_images_count} imagen(es) nueva(s). Ya tienes #{current_images_count} imagen(es) y el límite es 10."
          render :edit, status: :unprocessable_entity
          return
        end
      end

      if @product.update(update_hash)
        @product.audio.purge if previous_condition == "used" && @product.condition == "new" && @product.audio.attached?

        if @product.condition == "used" && params[:product][:audio].present?
          @product.audio.attach(params[:product][:audio])

          unless @product.valid?
            render :edit, status: :unprocessable_entity
            return
          end
        end

        if params[:product][:images].present?
          new_images = params[:product][:images].reject(&:blank?)
          @product.images.attach(new_images)

          unless @product.valid?
            render :edit, status: :unprocessable_entity
            return
          end
        end

        redirect_to backstore_product_path(@product), notice: "Producto actualizado"
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
      image = @product.images.find(params[:image_id])

      if @product.images.count <= 1
        redirect_back fallback_location: edit_backstore_product_path(@product),
                      alert: "No se puede eliminar la última imagen. Debe quedar al menos una."
        return
      end

      image.purge
      redirect_back fallback_location: edit_backstore_product_path(@product),
                    notice: "Imagen eliminada correctamente."
    end

    def delete_audio_attachment
      if @product.audio.attached?
        @product.audio.purge
        redirect_to edit_backstore_product_path(@product), notice: "Audio eliminado correctamente."
      else
        redirect_to edit_backstore_product_path(@product), alert: "No hay audio para eliminar."
      end
    end

    def change_stock
      stock_param = params.dig(:product, :stock)
      new_stock_value = stock_param.present? ? stock_param.to_i : nil

      if new_stock_value.is_a?(Integer) && new_stock_value >= 0
        update_attributes = { stock: new_stock_value }

        if @product.respond_to?(:last_modified_at) && @product.class.validators_on(:last_modified_at).any?
          update_attributes[:last_modified_at] = Time.current
        end

        if @product.update(update_attributes)
          redirect_to backstore_product_path(@product), notice: "Stock actualizado correctamente."
        else
          redirect_to backstore_product_path(@product), alert: "Error al actualizar stock: #{@product.errors.full_messages.join(', ')}"
        end
      else
        redirect_to backstore_product_path(@product), alert: "El valor de stock ingresado no es válido."
      end
    end

    private

    def product_params
      params.require(:product).permit(
        :name, :author, :category_id, :price, :stock,
        :product_type, :condition, :release_year, :description,
        :audio,
        images: []
      )
    end
  end
end
