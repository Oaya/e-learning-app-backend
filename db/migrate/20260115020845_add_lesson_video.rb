class AddLessonVideo < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :video_name, :string
    rename_column :lessons, :content_url, :video_key
    add_column :lessons, :article, :string
    add_column :courses, :thumbnail_name, :string
  end
end
