class AddUniqueIndexesToCourseModulesAndLessons < ActiveRecord::Migration[8.1]
  def up
    remove_index :course_modules, column: [ :course_id, :order ] if index_exists?(:course_modules, [ :course_id, :order ])
    remove_column :course_modules, :order, :integer if column_exists?(:course_modules, :order)

    add_column :course_modules, :position, :integer, null: false unless column_exists?(:course_modules, :position)
    add_index :course_modules, [ :course_id, :position ], unique: true unless index_exists?(:course_modules, [ :course_id, :position ], unique: true)

    remove_index :lessons, column: [ :course_module_id, :order ] if index_exists?(:lessons, [ :course_module_id, :order ])
    remove_column :lessons, :order, :integer if column_exists?(:lessons, :order)

    add_column :lessons, :position, :integer, null: false unless column_exists?(:lessons, :position)
    add_index :lessons, [ :course_module_id, :position ], unique: true unless index_exists?(:lessons, [ :course_module_id, :position ], unique: true)
  end

  def down
    remove_index :course_modules, column: [ :course_id, :position ] if index_exists?(:course_modules, [ :course_id, :position ])
    remove_column :course_modules, :position, :integer if column_exists?(:course_modules, :position)

    add_column :course_modules, :order, :integer, null: false unless column_exists?(:course_modules, :order)
    add_index :course_modules, [ :course_id, :order ] unless index_exists?(:course_modules, [ :course_id, :order ])

    remove_index :lessons, column: [ :course_module_id, :position ] if index_exists?(:lessons, [ :course_module_id, :position ])
    remove_column :lessons, :position, :integer if column_exists?(:lessons, :position)

    add_column :lessons, :order, :integer, null: false unless column_exists?(:lessons, :order)
    add_index :lessons, [ :course_module_id, :order ] unless index_exists?(:lessons, [ :course_module_id, :order ])
  end
end
