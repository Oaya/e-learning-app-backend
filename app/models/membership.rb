class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :tenant

  enum role: {
    admin: "Admin",
    instructor: "Instructor",
    student: "Student"
  }

  validate :role, presence: true
end
