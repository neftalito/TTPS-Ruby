class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category
  has_many :sale_items
  has_many_attached :images
  has_one_attached :audio

  enum :product_type, { vinyl: "vinyl", cd: "cd" }, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true

  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered_recent, -> { order(created_at: :desc) }
  scope :with_category, -> { includes(:category) }
  scope :with_category_and_attachments, -> { includes(:category, images_attachments: :blob) }

  scope :available_products, lambda {
    kept
      .published
      .with_category
      .ordered_recent
  }

  scope :with_status, lambda { |status|
    case status
    when "deleted"
      only_deleted
    when "all"
      with_deleted
    else
      available_products
    end
  }

  scope :by_category, ->(category_id) { where(category_id:) if category_id.present? }

  scope :search_by_name, lambda { |name_query|
    if name_query.present?
      query = "%#{name_query.downcase}%"
      where("LOWER(name) LIKE ?", query)
    end
  }

  scope :search_by_author, lambda { |author_query|
    if author_query.present?
      query = "%#{author_query.downcase}%"
      where("LOWER(author) LIKE ?", query)
    end
  }

  scope :by_condition, lambda { |condition_param|
    if condition_param.present? && condition_param != "all"
      where(condition: condition_param)
    end
  }

  scope :by_product_type, lambda { |product_type_param|
    if product_type_param.present? && product_type_param != "all"
      where(product_type: product_type_param)
    end
  }

  scope :released_in_year, ->(release_year) { where(release_year: release_year.to_i) if release_year.present? }

  scope :low_stock_new, lambda { |limit_value = 5|
    kept
      .where(condition: "new")
      .where("stock <= ?", limit_value)
      .order(:stock)
      .limit(limit_value)
  }

  validates :name, presence: true
  validates :description, presence: true
  validates :author, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :last_modified_at, presence: true
  validates :release_year,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1900,
              less_than_or_equal_to: Date.current.year,
              message: "debe ser un año válido entre 1900 y el año actual"
            }

  validate :must_have_at_least_one_image
  validate :audio_only_for_used_products
  validate :validate_images_format_and_size
  validate :validate_audio_format_and_size

  # Callback: si el producto cambia a nuevo, eliminar el audio
  before_validation :remove_audio_if_new
  before_validation :force_stock_to_one_if_used, if: :should_force_stock_to_one?
  before_discard :reset_stock
  validate :used_stock_cannot_exceed_one

  def label_for_select
    condicion = condition_new? ? "NUEVO" : "USADO"
    tipo = product_type_vinyl? ? "VINILO" : "CD"

    "#{name} - #{author} (#{tipo}, #{condicion})"
  end

  def label_for_sale
    condicion = condition_new? ? "NUEVO" : "USADO"
    tipo = product_type_vinyl? ? "VINILO" : "CD"

    "#{name} (#{tipo}, #{condicion})"
  end

  def label_for_type
    product_type_vinyl? ? "VINILO" : "CD"
  end

  def label_for_condition
    condition_new? ? "NUEVO" : "USADO"
  end

  def self.related_to(product, limit: 4)
    available_products
      .where(category_id: product.category_id)
      .where.not(id: product.id)
      .order("RANDOM()")
      .limit(limit)
  end

  def self.search_by_term(term)
    return none if term.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(term.downcase)

    available_products
      .where("LOWER(products.name) LIKE :term OR LOWER(products.description) LIKE :term", term: "%#{sanitized}%")
  end

  def has_stock?(quantity_needed)
    stock >= quantity_needed
  end

  def decrement_stock!(quantity)
    self.stock -= quantity
    save!
  end

  def increment_stock!(quantity)
    self.stock += quantity
    self.stock = 1 if condition_used? && stock > 1
    save!
  end

  def discard
    return false if discarded?

    timestamp = Time.current

    run_callbacks(:discard) do
      update_columns(self.class.discard_column => timestamp, deactivated_at: timestamp, updated_at: timestamp)
    end
  end

  def undiscard
    return false unless discarded?

    run_callbacks(:undiscard) do
      update_columns(self.class.discard_column => nil, deactivated_at: nil, updated_at: Time.current)
    end
  end

  private

  def must_have_at_least_one_image
    # En creación o edición, debe tener al menos 1 imagen
    return if images.attached? && images.any?

    errors.add(:images, "debe tener al menos una imagen")
  end

  def audio_only_for_used_products
    # Solo productos usados pueden tener audio
    return unless audio.attached? && condition == "new"

    errors.add(:audio, "solo puede adjuntarse a productos usados")
  end

  def remove_audio_if_new
    # Si el estado cambió de used a new, purgar el audio automáticamente
    return unless condition_changed? && condition == "new" && audio.attached?

    audio.purge
  end

  def reset_stock
    update_column(:stock, 0)
  end

  def should_force_stock_to_one?
    condition_used? && (new_record? || will_save_change_to_condition?)
  end

  def force_stock_to_one_if_used
    # Esto asegura que si la condición es 'used' al crear o cambiar el estado, el stock se normalice.
    self.stock = 1
  end

  def used_stock_cannot_exceed_one
    return unless condition_used? && stock.present? && stock > 1

    errors.add(:stock, "no puede ser mayor a 1 para productos usados")
  end

  def validate_images_format_and_size
    return unless images.attached?

    # Validar cantidad máxima (10 imágenes)
    if images.count > 10
      errors.add(:images, "no puede exceder las 10 imágenes")
      return
    end

    valid_formats = %w[image/jpeg image/jpg image/png image/gif image/webp]
    max_size = 10.megabytes

    images.each do |image|
      # Validar formato
      unless valid_formats.include?(image.content_type)
        errors.add(:images, "#{image.filename} no es un formato válido. Formatos permitidos: JPEG,JPG, PNG, GIF, WebP")
      end

      # Validar tamaño
      if image.byte_size > max_size
        size_mb = (image.byte_size.to_f / 1.megabyte).round(2)
        errors.add(:images, "#{image.filename} es demasiado grande (#{size_mb} MB). Tamaño máximo: 10 MB por imagen")
      end
    end
  end

  def validate_audio_format_and_size
    return unless audio.attached?

    valid_formats = %w[audio/mpeg audio/mp3 audio/wav audio/ogg audio/m4a audio/flac audio/x-m4a]
    max_size = 15.megabytes

    # Validar formato
    unless valid_formats.include?(audio.content_type)
      errors.add(:audio, "#{audio.filename} no es un formato válido. Formatos permitidos: MP3, WAV, OGG, M4A, FLAC")
    end

    # Validar tamaño
    return unless audio.byte_size > max_size

    size_mb = (audio.byte_size.to_f / 1.megabyte).round(2)
    errors.add(:audio, "#{audio.filename} es demasiado grande (#{size_mb} MB). Tamaño máximo: 15 MB")
  end
end
