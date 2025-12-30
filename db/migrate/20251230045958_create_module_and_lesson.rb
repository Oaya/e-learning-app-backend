class CreateModuleAndLesson < ActiveRecord::Migration[8.1]
  def change
    create_table :course_modules, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :order, null: false

      t.references :tenant, type: :uuid, null: false, foreign_key: true
      t.references :course, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :course_modules, [ :course_id, :order ]

    create_table :lessons, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :order, null: false
      t.string :lesson_type, null: false
      t.integer :duration_in_minutes

      t.references :tenant, type: :uuid, null: false, foreign_key: true
      t.references :course_module, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
    add_index :lessons, [ :course_module_id, :order ]
  end
end
