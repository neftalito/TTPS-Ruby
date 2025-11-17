class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable
  
  enum :role, { employee: 0, manager: 1, admin: 2 }

  before_validation :set_default_role, on: :create

  validates :role, presence: true

  private

  def set_default_role
    self.role ||= :employee
  end
end
