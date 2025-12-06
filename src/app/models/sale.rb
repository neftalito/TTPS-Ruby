class Sale < ApplicationRecord
  SALES_IMMUTABLE_MESSAGE = "Las ventas no se pueden borrar.".freeze

  belongs_to :user
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  validates :buyer_name, :buyer_dni, :buyer_email, presence: { message: "es obligatorio" }

  accepts_nested_attributes_for :sale_items, allow_destroy: true

  before_destroy :prevent_destruction

  validate :validate_stock_availability, on: :create
  validate :must_have_at_least_one_item

  before_save :calculate_total

  after_create :decrement_stock_from_products
  def discard
    errors.add(:base, SALES_IMMUTABLE_MESSAGE)
    false
  end

  def discard!
    raise ActiveRecord::ReadOnlyRecord, SALES_IMMUTABLE_MESSAGE
  end

  def self.delete_all(*args)
    if Rails.env.development? && ENV["SKIP_SALE_PROTECTION"] == "1"
      super
    else
      raise ActiveRecord::ReadOnlyRecord, SALES_IMMUTABLE_MESSAGE
    end
  end

  class << self
    alias destroy_all delete_all
  end

  
  def cancel!
    return if cancelled?

    ActiveRecord::Base.transaction do
      update!(cancelled_at: Time.current)
      
      sale_items.each do |item|
        item.product.increment_stock!(item.quantity)
      end
    end
  end

  def cancelled?
    cancelled_at.present?
  end
  private


  def calculate_total
    self.total = sale_items.reduce(0) do |sum, item|
      price = item.unit_price || item.product&.price || 0
      qty = item.quantity || 0

      sum + (price * qty)
    end
  end

  def validate_stock_availability
    sale_items.each do |item|
      if item.product && !item.product.has_stock?(item.quantity)
        errors.add(:base, "No hay suficiente stock para el producto: #{item.product.label_for_select}, solicitado: #{item.quantity}, disponible: #{item.product.stock}")
      end
    end
  end

  def decrement_stock_from_products
    sale_items.each do |item|
      item.product.decrement_stock!(item.quantity)
    end
  end

  def prevent_destruction
    errors.add(:base, SALES_IMMUTABLE_MESSAGE)
    throw(:abort)
  end

  def must_have_at_least_one_item
    if sale_items.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "Debes agregar al menos un producto a la venta.")
    end
  end
end