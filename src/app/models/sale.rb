class Sale < ApplicationRecord
  SALES_IMMUTABLE_MESSAGE = "Las ventas no se pueden borrar.".freeze

  belongs_to :user
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  accepts_nested_attributes_for :sale_items, allow_destroy: true

  before_destroy :prevent_destruction

  validate :validate_stock_availability, on: :create

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
    return if cancelled? # Evitar cancelar dos veces

    ActiveRecord::Base.transaction do
      update!(cancelled_at: Time.current)
      
      # Devolver el stock de cada ítem
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
      # 1. Si el item no tiene precio (porque es nuevo), lo tomamos del producto
      if item.unit_price.nil? && item.product.present?
        item.unit_price = item.product.price
      end

      # 2. Validación de seguridad por si quantity o price son nil
      price = item.unit_price || 0
      qty = item.quantity || 0

      # 3. Sumamos
      sum + (price * qty)
    end
  end

  def validate_stock_availability
    sale_items.each do |item|
      # Si el producto no tiene stock suficiente, agregamos un error al modelo Sale
      if item.product && !item.product.has_stock?(item.quantity)
        errors.add(:base, "No hay suficiente stock para el producto: #{item.product.name}")
      end
    end
  end

  def decrement_stock_from_products
    sale_items.each do |item|
      # Al usar el signo ! (bang), si esto falla, Rails hace rollback de toda la venta
      item.product.decrement_stock!(item.quantity)
    end
  end

  def prevent_destruction
    errors.add(:base, SALES_IMMUTABLE_MESSAGE)
    throw(:abort)
  end
end