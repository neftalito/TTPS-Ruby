class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category

  has_many_attached :images
  has_one_attached :audio

  enum :product_type, { vinyl: "vinyl", cd: "cd" }, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true

  # Scope para productos no borrados lógicamente
  scope :available_products, -> { where(deleted_at: nil) }

  validates :author, presence: true
  validates :inventory_entered_at, :last_modified_at, presence: true

  validate :must_have_at_least_one_image
  validate :audio_only_for_used_products

  # Callback: si el producto cambia a nuevo, eliminar el audio
  before_validation :remove_audio_if_new

  

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
  
end