class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  include SoftDeletable

  devise :database_authenticatable, :registerable, :rememberable, :validatable

  enum :role, { employee: 0, manager: 1, admin: 2 }

  before_validation :set_default_role, on: :create
  before_validation :set_default_locale, on: :create

  validates :role, presence: true
  validates :locale, presence: true, inclusion: { in: I18n.available_locales.map(&:to_s) }

  scope :with_status, lambda { |status|
    case status
    when "deleted"
      only_deleted
    when "all"
      with_deleted
    else
      kept
    end
  }

  scope :with_role, ->(role) { where(role:) if role.present? }

  scope :search_by_email, lambda { |query|
    if query.present?
      sanitized_query = "%#{query.downcase}%"
      where("LOWER(email) LIKE ?", sanitized_query)
    end
  }

  def active_for_authentication?
    super && !deleted?
  end

  def inactive_message
    deleted? ? :inactive : super
  end

  private

  def set_default_role
    self.role ||= :employee
  end

  def set_default_locale
    self.locale ||= I18n.default_locale.to_s
  end
end
