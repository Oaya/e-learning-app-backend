class UpdateDurationInSecond < ActiveRecord::Migration[8.1]
  def change
    rename_column :lessons, :duration_in_minutes, :duration_in_seconds
  end
end
