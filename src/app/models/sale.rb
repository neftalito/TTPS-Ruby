class Sale < ApplicationRecord
  belongs_to :user
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  validates :buyer_name, :buyer_dni, :buyer_email, presence: { message: "es obligatorio" }

  accepts_nested_attributes_for :sale_items, allow_destroy: true

  before_save :calculate_total
  after_create :decrement_stock_from_products

  validate :validate_stock_availability, on: :create
  validate :must_have_at_least_one_item

  scope :confirmed, -> { where(cancelled_at: nil) }
  scope :ordered_recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user:) if user.present? }
  scope :between_dates, lambda { |start_date, end_date|
    if start_date && end_date
      where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  }

  scope :search_by_buyer, lambda { |query|
    if query.present?
      sanitized_query = "%#{query.downcase}%"
      where("LOWER(buyer_name) LIKE ? OR LOWER(buyer_email) LIKE ?", sanitized_query, sanitized_query)
    end
  }

  scope :with_status, lambda { |status|
    case status
    when "cancelled"
      where.not(cancelled_at: nil)
    when "confirmed"
      confirmed
    else
      all
    end
  }

  def self.chart_totals_by_day(range: 1.week.ago..Time.current)
    confirmed.group_by_day(:created_at, range: range).sum(:total)
  end

  def self.recent_confirmed(limit: 5)
    confirmed.includes(:user).ordered_recent.limit(limit)
  end

  def self.total_revenue_for_user(user)
    confirmed.for_user(user).sum(:total)
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
        errors.add(:base,
                   "No hay suficiente stock para el producto: #{item.product.label_for_select}, solicitado: #{item.quantity}, disponible: #{item.product.stock}")
      end
    end
  end

  def decrement_stock_from_products
    sale_items.each do |item|
      item.product.decrement_stock!(item.quantity)
    end
  end

  def must_have_at_least_one_item
    return unless sale_items.reject(&:marked_for_destruction?).empty?

    errors.add(:base, "Debes agregar al menos un producto a la venta.")
  end
end
