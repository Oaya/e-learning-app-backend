class CourseInstructors < ActiveRecord::Migration[8.1]
  def change
    create_table :course_instructors, id: :uuid do |t|
      t.uuid :course_id, null: false
      t.uuid :instructor_id, null: false
      t.timestamps
    end

    add_column :users, :avatar, :string

    add_index :course_instructors, [:course_id, :instructor_id], unique: true
    add_index :course_instructors, :instructor_id

    add_foreign_key :course_instructors, :courses
    add_foreign_key :course_instructors, :users, column: :instructor_id
  end
end
