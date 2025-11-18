class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category

  has_many_attached :images

  enum :product_type, {vinyl: "viniyl", cd: "cd"}, prefix: true
  enum :condition, { new: "new", used: "used" }, prefix: true

  validates :author, presence: true
  validates :inventory_entered_at, :last_modified_at, presence: true
end
