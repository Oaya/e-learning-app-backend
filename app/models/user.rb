class User < ApplicationRecord
  belongs_to :tenant
  has_one :membership, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, :last_name, :email, :tenant_id, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :status, presence: true

  enum :status, {
    active: "Active",
    inactive: "Inactive",
    closed: "Closed",
    invited: "Invited"
  }, validate: true


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
