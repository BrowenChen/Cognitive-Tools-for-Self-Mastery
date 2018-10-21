class RemoveTimestampsFromPoints < ActiveRecord::Migration
  def change
    remove_column :points, :created_at, :datetime
    remove_column :points, :updated_at, :datetime
  end
end
