class Cart < ApplicationRecord
  belongs_to :user

  enum :status, { active: 0, abandoned: 1, purchased: 2 }
end
