class Tenant < ApplicationRecord
  belongs_to :plan
  has_many :courses
  has_many :sections
  has_many :lessons
  has_many :memberships
  has_many :users, through: :memberships

  validates :name, presence: true, uniqueness: true
  validates :plan_id, presence: true
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  enum :status, {
    active: "Active",
    inactive: "Inactive",
    closed: "Closed",
    pending: "Pending"
  }, validate: true
end
