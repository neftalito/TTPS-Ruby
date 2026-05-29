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
      @products = @products.with_category_and_attachments

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
      @product.assign_attributes(product_update_params)
      @product.stock = 1 if @product.condition == "used"
      @product.last_modified_at = Time.current

      uploaded_images = new_product_images
      uploaded_audio = new_product_audio
      removed_audio_blob = audio_blob_marked_for_removal

      if invalid_uploaded_media?(uploaded_images, uploaded_audio)
        render :edit, status: :unprocessable_entity
        return
      end

      updated = false

      ActiveRecord::Base.transaction do
        @product.audio.detach if should_remove_existing_audio?
        @product.images.attach(uploaded_images) if uploaded_images.any?
        @product.audio.attach(uploaded_audio) if should_attach_audio?(uploaded_audio)

        updated = @product.save
        raise ActiveRecord::Rollback unless updated
      end

      if updated
        purge_removed_audio_blob(removed_audio_blob)
        redirect_to backstore_product_path(@product), notice: "Producto actualizado"
      else
        restore_persisted_media_state
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
                      alert: "No se puede eliminar la ultima imagen. Debe quedar al menos una."
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
          redirect_to backstore_product_path(@product),
                      alert: "Error al actualizar stock: #{@product.errors.full_messages.join(', ')}"
        end
      else
        redirect_to backstore_product_path(@product), alert: "El valor de stock ingresado no es valido."
      end
    end

    private

    def product_update_params
      product_params.except(:images, :audio)
    end

    def new_product_images
      Array(params.dig(:product, :images)).reject(&:blank?)
    end

    def new_product_audio
      params.dig(:product, :audio)
    end

    def invalid_uploaded_media?(uploaded_images, uploaded_audio)
      validate_total_images_limit(uploaded_images)
      validate_uploaded_images(uploaded_images)
      validate_uploaded_audio(uploaded_audio)
      @product.errors.any?
    end

    def validate_total_images_limit(uploaded_images)
      return if uploaded_images.empty?

      new_images_count = uploaded_images.size
      current_images_count = @product.images.count
      total_images = current_images_count + new_images_count
      return unless total_images > 10

      @product.errors.add(
        :images,
        "no puedes subir #{new_images_count} imagen(es) nueva(s). Ya tienes #{current_images_count} imagen(es) y el limite es 10."
      )
    end

    def validate_uploaded_images(uploaded_images)
      uploaded_images.each do |image|
        next unless image.respond_to?(:content_type) && image.respond_to?(:size) && image.respond_to?(:original_filename)

        unless Product::VALID_IMAGE_CONTENT_TYPES.include?(image.content_type)
          @product.errors.add(
            :images,
            "#{image.original_filename} no es un formato valido. Formatos permitidos: JPEG, JPG, PNG, GIF, WebP"
          )
        end

        next unless image.size > Product::MAX_IMAGE_SIZE

        size_mb = (image.size.to_f / 1.megabyte).round(2)
        @product.errors.add(
          :images,
          "#{image.original_filename} es demasiado grande (#{size_mb} MB). Tamano maximo: 10 MB por imagen"
        )
      end
    end

    def validate_uploaded_audio(uploaded_audio)
      return unless should_attach_audio?(uploaded_audio)
      return unless uploaded_audio.respond_to?(:content_type) && uploaded_audio.respond_to?(:size) &&
                    uploaded_audio.respond_to?(:original_filename)

      unless Product::VALID_AUDIO_CONTENT_TYPES.include?(uploaded_audio.content_type)
        @product.errors.add(
          :audio,
          "#{uploaded_audio.original_filename} no es un formato valido. Formatos permitidos: MP3, WAV, OGG, M4A, FLAC"
        )
      end

      return unless uploaded_audio.size > Product::MAX_AUDIO_SIZE

      size_mb = (uploaded_audio.size.to_f / 1.megabyte).round(2)
      @product.errors.add(
        :audio,
        "#{uploaded_audio.original_filename} es demasiado grande (#{size_mb} MB). Tamano maximo: 15 MB"
      )
    end

    def should_remove_existing_audio?
      @product.condition == "new" && @product.audio.attached?
    end

    def audio_blob_marked_for_removal
      @product.audio.blob if should_remove_existing_audio?
    end

    def purge_removed_audio_blob(audio_blob)
      return unless audio_blob
      return if audio_blob.attachments.exists?

      audio_blob.purge
    end

    def restore_persisted_media_state
      @product.attachment_changes.delete("audio")
      @product.attachment_changes.delete("images")
      @product.association(:audio_attachment).reset
      @product.association(:audio_blob).reset
      @product.association(:images_attachments).reset
      @product.association(:images_blobs).reset
    end

    def should_attach_audio?(uploaded_audio)
      @product.condition == "used" && uploaded_audio.present?
    end

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
