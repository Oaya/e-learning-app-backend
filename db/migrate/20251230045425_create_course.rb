class CreateCourse < ActiveRecord::Migration[8.1]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.boolean :published, default: false
      t.references :tenant, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
