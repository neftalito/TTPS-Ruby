class Sale < ApplicationRecord
  SALES_IMMUTABLE_MESSAGE = "Las ventas no se pueden borrar.".freeze

  belongs_to :user
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  accepts_nested_attributes_for :sale_items, allow_destroy: true

  before_destroy :prevent_destruction

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

  private

  def prevent_destruction
    errors.add(:base, SALES_IMMUTABLE_MESSAGE)
    throw(:abort)
  end
end