# frozen_string_literal: true

class ProductImage < ApplicationRecord
  belongs_to :product

  validates :url, presence: true
end