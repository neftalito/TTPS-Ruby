class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_create :set_unit_price

  private

  def set_unit_price
    self.unit_price = product.price if unit_price.blank?
  end
  
end
