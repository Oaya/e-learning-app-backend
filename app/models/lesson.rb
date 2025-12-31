class Lesson < ApplicationRecord
  belongs_to :tenant
  belongs_to :course_module

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create
  validates :lesson_type, presence: true, on: :create
  validates :position, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :course_module_id }


  before_validation :assign_position, on: :create
  # Auto assign the position when it's created
  def assign_position
    return if position.present?

    self.position = course_modules.lessons.maximum(:position).to_i + 1
  end
end
