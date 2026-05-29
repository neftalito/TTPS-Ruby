class Product < ApplicationRecord
  include SoftDeletable
  attr_accessor :remove_existing_audio

  belongs_to :category
  has_many :sale_items
  has_many_attached :images
  has_one_attached :audio

  enum :product_type, { vinyl: "vinyl", cd: "cd" }, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true

  VALID_IMAGE_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/gif image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes
  VALID_AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/ogg audio/m4a audio/flac audio/x-m4a].freeze
  MAX_AUDIO_SIZE = 15.megabytes

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

  scope :available_products_with_stock, lambda {
    available_products
      .where("stock > 0")
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
              message: :invalid_release_year
            }

  validate :must_have_at_least_one_image
  validate :audio_only_for_used_products
  validate :validate_images_format_and_size
  validate :validate_audio_format_and_size
  validate :used_stock_cannot_exceed_one

  before_validation :force_stock_to_one_if_used, if: :should_force_stock_to_one?
  before_discard :reset_stock

  def label_for_select
    "#{name} - #{author} (#{human_product_type.upcase}, #{human_condition.upcase})"
  end

  def label_for_sale
    "#{name} (#{human_product_type.upcase}, #{human_condition.upcase})"
  end

  def label_for_type
    human_product_type.upcase
  end

  def label_for_condition
    human_condition.upcase
  end

  def human_product_type
    I18n.t("products.types.#{normalized_product_type_value}", default: normalized_product_type_value.humanize)
  end

  def human_condition
    I18n.t("products.conditions.#{condition}", default: condition.to_s.humanize)
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
    return if images.attached? && images.any?

    errors.add(:images, :at_least_one_image)
  end

  def audio_only_for_used_products
    return if audio_marked_for_removal?
    return unless audio.attached? && condition == "new"

    errors.add(:audio, :audio_only_for_used_products)
  end

  def reset_stock
    update_column(:stock, 0)
  end

  def should_force_stock_to_one?
    condition_used? && (new_record? || will_save_change_to_condition?)
  end

  def force_stock_to_one_if_used
    self.stock = 1
  end

  def used_stock_cannot_exceed_one
    return unless condition_used? && stock.present? && stock > 1

    errors.add(:stock, :used_stock_cannot_exceed_one)
  end

  def validate_images_format_and_size
    return unless images.attached?

    if images.count > 10
      errors.add(:images, :too_many_images, limit: 10)
      return
    end

    images.each do |image|
      unless VALID_IMAGE_CONTENT_TYPES.include?(image.content_type)
        errors.add(:images, :invalid_image_format, filename: image.filename.to_s, formats: "JPEG, JPG, PNG, GIF, WebP")
      end

      if image.byte_size > MAX_IMAGE_SIZE
        size_mb = (image.byte_size.to_f / 1.megabyte).round(2)
        errors.add(:images, :image_too_large, filename: image.filename.to_s, size_mb:, max_size_mb: 10)
      end
    end
  end

  def validate_audio_format_and_size
    return if audio_marked_for_removal?
    return unless audio.attached?

    unless VALID_AUDIO_CONTENT_TYPES.include?(audio.content_type)
      errors.add(:audio, :invalid_audio_format, filename: audio.filename.to_s, formats: "MP3, WAV, OGG, M4A, FLAC")
    end

    return unless audio.byte_size > MAX_AUDIO_SIZE

    size_mb = (audio.byte_size.to_f / 1.megabyte).round(2)
    errors.add(:audio, :audio_too_large, filename: audio.filename.to_s, size_mb:, max_size_mb: 15)
  end

  def audio_marked_for_removal?
    ActiveModel::Type::Boolean.new.cast(remove_existing_audio)
  end

  def normalized_product_type_value
    value = product_type.to_s
    value == "viniyl" ? "vinyl" : value
  end
end
