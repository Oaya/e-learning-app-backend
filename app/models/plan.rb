class Plan < ApplicationRecord
  has_many :tenants

  validates :name, presence: true, on: :create
  validate :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
