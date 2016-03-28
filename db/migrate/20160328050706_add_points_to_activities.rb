class AddPointsToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :points, :decimal
  end
end
