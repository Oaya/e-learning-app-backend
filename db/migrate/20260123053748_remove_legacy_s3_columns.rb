class RemoveLegacyS3Columns < ActiveRecord::Migration[8.1]
  def change
    # courses
    remove_column :courses, :thumbnail_key, :string
    remove_column :courses, :thumbnail_name, :string

    # lessons
    remove_column :lessons, :video_key, :string
    remove_column :lessons, :video_name, :string
  end
end
