class Course < ApplicationRecord
  belongs_to :tenant
  has_many :course_modules, dependent: :destroy

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create
end
