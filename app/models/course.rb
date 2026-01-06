class Course < ApplicationRecord
  belongs_to :tenant
  has_many :sections, dependent: :destroy

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create

  enum :category, {
   development: "Development",
    business: "Business",
    finance: "Finance",
    it_software: "IT & Software",
    design: "Design",
    marketing: "Marketing",
    personal_development: "Personal Development",
    photography: "Photography",
    health_fitness: "Health & Fitness",
    music: "Music",
    teaching_academics: "Teaching & Academics",
    lifestyle: "Lifestyle"
  }

  enum :level, {
    beginner: "Beginner",
    intermediate: "Intermediate",
    advanced: "Advanced",
    all_levels: "All Levels"
  }
end
