class Product < ApplicationRecord
  include SoftDeletable

  belongs_to :category

  has_many_attached :images
end
