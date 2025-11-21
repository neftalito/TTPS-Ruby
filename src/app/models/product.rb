class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category

  has_many_attached :images
  has_one_attached :audio

  enum :product_type, {vinyl: "viniyl", cd: "cd"}, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true
  enum :product_state, { new_disc: 0, used_disc: 1 }
  # Scope para productos no borrados lógicamente
  scope :available_products, -> { where(deleted_at: nil) }

  validates :author, presence: true
  validates :inventory_entered_at, :last_modified_at, presence: true
end
