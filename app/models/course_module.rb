class CourseModule < ApplicationRecord
  belongs_to :tenant
  belongs_to :course
  has_many :lessons

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create
  validates :order, presence: true, on: :create
end
