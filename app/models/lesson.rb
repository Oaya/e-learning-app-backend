class Lesson < ApplicationRecord
  belongs_to :tenant
  belongs_to :section

  validates :title, presence: true, on: :create
  validates :lesson_type, presence: true, on: :create
  validates :position, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :section_id }


  enum :lesson_type, {
    video: "Video",
    reading: "Reading"
  }


  before_validation :assign_position, on: :create
  after_destroy :move_positions

  # Auto assign the position when it's created
  def assign_position
    return if position.present?

    self.position = section.lessons.maximum(:position).to_i + 1
  end

  def move_positions
    return if position.nil?

    Lesson.where(section_id: section_id).where("position > ?", position).update_all("position = position - 1")
  end
end
