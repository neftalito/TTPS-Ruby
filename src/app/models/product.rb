class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category
  has_many :sale_items
  has_many_attached :images
  has_one_attached :audio

  enum :product_type, { vinyl: "vinyl", cd: "cd" }, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true

  # Scopes
  
  scope :available_products, -> { kept.includes(:category).order(created_at: :desc) }
  
  validates :author, presence: true
  validates :inventory_entered_at, :last_modified_at, presence: true

  validate :must_have_at_least_one_image
  validate :audio_only_for_used_products
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  # Callback: si el producto cambia a nuevo, eliminar el audio
  before_validation :remove_audio_if_new
  before_validation :force_stock_to_one_if_used, if: -> { self.condition_used? }
  before_discard :reset_stock
  

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

  def has_stock?(quantity_needed)
    stock >= quantity_needed
  end

  def decrement_stock!(quantity)
    self.stock -= quantity
    save! 
  end

  def increment_stock!(quantity)
    self.stock += quantity
    save!
  end
  private

  def must_have_at_least_one_image
    # En creación o edición, debe tener al menos 1 imagen
    unless images.attached? && images.any?
      errors.add(:images, "debe tener al menos una imagen")
    end
  end


  def audio_only_for_used_products
    # Solo productos usados pueden tener audio
    if audio.attached? && condition == "new"
      errors.add(:audio, "solo puede adjuntarse a productos usados")
    end
  end

  def remove_audio_if_new
    # Si el estado cambió de used a new, purgar el audio automáticamente
    if condition_changed? && condition == "new" && audio.attached?
      audio.purge
    end
  end

  def reset_stock
    self.update_column(:stock, 0)
  end

  def force_stock_to_one_if_used
    # Esto asegura que si la condición es 'used', el stock no puede ser otro valor.
    self.stock = 1
  end

end