class Tenant < ApplicationRecord
  belongs_to :plan

  validates :name, presence: true, uniqueness: true
end
