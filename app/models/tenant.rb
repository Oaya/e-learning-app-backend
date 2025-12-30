class Tenant < ApplicationRecord
  belongs_to :plan
  has_many :courses

  validates :name, presence: true, uniqueness: true
end
