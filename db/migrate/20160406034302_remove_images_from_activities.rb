class RemoveImagesFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :image_file_name, :string
    remove_column :activities, :image_file_size, :decimal
    remove_column :activities, :image_content_type, :string
    remove_column :activities, :image_updated_at, :date
  end
end
