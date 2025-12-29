class User < ApplicationRecord
  belongs_to :tenant

  validates :first_name, :last_name, :email, :tenant_id, presence: true, on: :create


  # This add devise api with users
  devise :invitable,
      :database_authenticatable,
      :registerable,
      :recoverable,
      :rememberable,
      :confirmable,
      :validatable,
      :jwt_authenticatable,
      jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
end
