class User < ApplicationRecord
  belongs_to :tenant

  validates :first_name, :last_name, :email, :tenant_id, presence: true, on: :create
end
