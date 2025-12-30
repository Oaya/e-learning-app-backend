class Lesson < ApplicationRecord
  belongs_to :tenant
  belongs_to :courseModule

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create
  validates :lesson_type, presence: true, on: :create
  validates :order, presence: true, on: :create
end
