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

      per_page = sanitized_per_page(
        params[:per_page],
        default: DEFAULT_BACKSTORE_PER_PAGE,
        max: MAX_BACKSTORE_PER_PAGE
      )
      @products = @products.order(id: :asc).page(params[:page]).per(per_page)
    end

    def show; end

    def new; end

    def edit; end

    def create
      @product.stock = 1 if @product.condition == "used"
      @product.last_modified_at = Time.current

      if @product.save
        redirect_to backstore_product_path(@product), notice: I18n.t("flash.backstore.products.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @product.assign_attributes(product_update_params)
      @product.stock = 1 if @product.condition == "used"
      @product.last_modified_at = Time.current
      @product.remove_existing_audio = should_remove_existing_audio?

      uploaded_images = new_product_images
      uploaded_audio = new_product_audio
      original_audio_blob = @product.audio.blob if @product.audio.attached?
      attempted_attributes = product_update_params.to_h

      if invalid_uploaded_media?(uploaded_images, uploaded_audio)
        render :edit, status: :unprocessable_entity
        return
      end

      updated = false

      ActiveRecord::Base.transaction do
        @product.images.attach(uploaded_images) if uploaded_images.any?
        @product.audio.attach(uploaded_audio) if should_attach_audio?(uploaded_audio)

        updated = @product.save
        raise ActiveRecord::Rollback unless updated
      end

      if updated
        remove_existing_audio_after_success(original_audio_blob)
        redirect_to backstore_product_path(@product), notice: I18n.t("flash.backstore.products.updated")
      else
        rebuild_product_for_failed_update(attempted_attributes)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.discard
        redirect_to backstore_products_path, notice: I18n.t("flash.backstore.products.deleted")
      else
        redirect_to backstore_products_path, alert: I18n.t("flash.backstore.products.delete_failed")
      end
    end

    def restore
      if @product.undiscard
        redirect_to backstore_products_path, notice: I18n.t("flash.backstore.products.restored")
      else
        redirect_to backstore_products_path, alert: I18n.t("flash.backstore.products.restore_failed")
      end
    end

    def delete_image_attachment
      image = @product.images.find(params[:image_id])

      if @product.images.count <= 1
        redirect_back fallback_location: edit_backstore_product_path(@product),
                      alert: I18n.t("flash.backstore.products.last_image")
        return
      end

      image.purge
      redirect_back fallback_location: edit_backstore_product_path(@product),
                    notice: I18n.t("flash.backstore.products.image_deleted")
    end

    def delete_audio_attachment
      if @product.audio.attached?
        @product.audio.purge
        redirect_to edit_backstore_product_path(@product), notice: I18n.t("flash.backstore.products.audio_deleted")
      else
        redirect_to edit_backstore_product_path(@product), alert: I18n.t("flash.backstore.products.no_audio")
      end
    end

    def change_stock
      new_stock_value = Integer(params.dig(:product, :stock), exception: false)

      if new_stock_value&.>= 0
        update_attributes = { stock: new_stock_value }

        if @product.respond_to?(:last_modified_at) && @product.class.validators_on(:last_modified_at).any?
          update_attributes[:last_modified_at] = Time.current
        end

        if @product.update(update_attributes)
          redirect_to backstore_product_path(@product), notice: I18n.t("flash.backstore.products.stock_updated")
        else
          redirect_to backstore_product_path(@product),
                      alert: I18n.t("flash.backstore.products.stock_update_error", errors: @product.errors.full_messages.join(", "))
        end
      else
        redirect_to backstore_product_path(@product), alert: I18n.t("flash.backstore.products.stock_invalid")
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
        :too_many_new_uploads,
        new_count: new_images_count,
        current_count: current_images_count,
        limit: 10
      )
    end

    def validate_uploaded_images(uploaded_images)
      uploaded_images.each do |image|
        next unless image.respond_to?(:content_type) && image.respond_to?(:size) && image.respond_to?(:original_filename)

        unless Product::VALID_IMAGE_CONTENT_TYPES.include?(image.content_type)
          @product.errors.add(
            :images,
            :invalid_image_format,
            filename: image.original_filename,
            formats: "JPEG, JPG, PNG, GIF, WebP"
          )
        end

        next unless image.size > Product::MAX_IMAGE_SIZE

        size_mb = (image.size.to_f / 1.megabyte).round(2)
        @product.errors.add(
          :images,
          :image_too_large,
          filename: image.original_filename,
          size_mb:,
          max_size_mb: 10
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
          :invalid_audio_format,
          filename: uploaded_audio.original_filename,
          formats: "MP3, WAV, OGG, M4A, FLAC"
        )
      end

      return unless uploaded_audio.size > Product::MAX_AUDIO_SIZE

      size_mb = (uploaded_audio.size.to_f / 1.megabyte).round(2)
      @product.errors.add(
        :audio,
        :audio_too_large,
        filename: uploaded_audio.original_filename,
        size_mb:,
        max_size_mb: 15
      )
    end

    def should_remove_existing_audio?
      @product.condition == "new" && @product.audio.attached?
    end

    def remove_existing_audio_after_success(original_audio_blob)
      return unless ActiveModel::Type::Boolean.new.cast(@product.remove_existing_audio)
      return unless @product.audio.attached?

      @product.audio.detach
      purge_removed_audio_blob(original_audio_blob)
    end

    def purge_removed_audio_blob(audio_blob)
      return unless audio_blob
      return if audio_blob.attachments.exists?

      audio_blob.purge
    end

    def rebuild_product_for_failed_update(attempted_attributes)
      persisted_product = Product.includes(:category, { images_attachments: :blob }, { audio_attachment: :blob })
                                 .find(@product.id)
      collected_errors = @product.errors.map { |error| [error.attribute, error.message] }

      persisted_product.assign_attributes(attempted_attributes)
      persisted_product.remove_existing_audio = false

      collected_errors.each do |attribute, message|
        persisted_product.errors.add(attribute, message)
      end

      @product = persisted_product
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
