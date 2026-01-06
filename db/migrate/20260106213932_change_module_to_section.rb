class ChangeModuleToSection < ActiveRecord::Migration[8.1]
  def change
    rename_table :course_modules, :sections
    rename_column :lessons, :course_module_id, :section_id

    remove_foreign_key :lessons, column: :section_id


    add_foreign_key :lessons, :sections, column: :section_id
  end
end
