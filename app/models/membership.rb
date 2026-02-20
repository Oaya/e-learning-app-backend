class Membership < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :tenant

  enum :role, {
    admin: "admin",
    instructor: "instructor",
    student: "student"
  }, validate: true
end
