class User < ApplicationRecord
  include Filterable

  belongs_to :tenant
  has_one :membership, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, :last_name, :email, :tenant_id, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :status, presence: true

  # # Add scopes for filters
  scope :filter_by_status, ->(status) do
    status.present? ? where(status: status.split(",")) : all
  end

  scope :filter_by_email, ->(email) {
    if email.present?
      pattern = "%#{sanitize_sql_like(email)}%"
      where("users.email ILIKE ?", pattern)
    else
      all
    end
  }

  scope :filter_by_name, ->(name) {
    if name.present?
      pattern = "%#{sanitize_sql_like(name)}%"
      where("users.first_name ILIKE :q OR users.last_name ILIKE :q", q: pattern)
    else
      all
    end
  }

  scope :filter_by_role, ->(role) {
    role.present? ? joins(:membership).where(memberships: { role: role.split(",") }) : all
  }


  enum :status, {
    active: "active",
    inactive: "inactive",
    invited: "invited"
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
