class MakeLessonDescriptionNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :lessons, :description, true
    add_column :lessons, :content_url, :string
  end
end
