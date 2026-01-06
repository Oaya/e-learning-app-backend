class Tenant < ApplicationRecord
  belongs_to :plan
  has_many :courses
  has_many :sections
  has_many :lessons
  has_many :memberships

  validates :name, presence: true, uniqueness: true
end
