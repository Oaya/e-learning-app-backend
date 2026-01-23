class CourseInstructor < ApplicationRecord
  belongs_to :course
  belongs_to :instructor, class_name: "User"

  validates :course_id, presence: true
  validates :instructor_id, presence: true
end