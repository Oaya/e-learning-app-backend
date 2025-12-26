 # This file should ensure the existence of records required to run the application in every environment (production,
 # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
 # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
 #
 # Example:
 #
 #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
 #     MovieGenre.find_or_create_by!(name: genre_name)
 #   end
 plans = [
  {
    name: "free",
    price: 0,
    features: {
      max_courses: 1,
      max_students: 10,
      quizzes: false
    }
  },
  {
    name: "standard",
    price: 10,
    features: {
      max_courses: 10,
      max_students: 100,
      quizzes: true
    }
  },
  {
    name: "premium",
    price: 30,
    features: {
      max_courses: 50,
      max_students: 500,
      quizzes: true
    }
  }
]

plans.each do |plan|
  pp plan
  Plan.create!(name: plan[:name], price: plan[:price], features: plan[:features])
end
