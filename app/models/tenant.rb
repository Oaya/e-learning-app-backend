class Tenant < ApplicationRecord
  belongs_to :plan

  validates :name, :plan_id, presence: true, on: :create
end
