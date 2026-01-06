class AddCategory < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :category, :string
    add_column :courses, :level, :string
    add_column :courses, :thumbnail, :string
  end
end
