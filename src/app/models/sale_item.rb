class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_create :set_unit_price

  scope :for_sales, ->(sales_scope) { where(sale: sales_scope) }

  def self.category_quantities
    joins(product: :category)
      .group("categories.name")
      .sum(:quantity)
  end

  def self.total_quantity_for_sales(sales_scope)
    for_sales(sales_scope).sum(:quantity)
  end

  def self.ranking_for_sales(sales_scope)
    for_sales(sales_scope)
      .group(:product_id)
      .sum(:quantity)
      .sort_by { |_id, qty| -qty }
  end

  private

  def set_unit_price
    self.unit_price = product.price if unit_price.blank?
  end
end
