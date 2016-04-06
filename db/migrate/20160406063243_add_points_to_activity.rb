class AddPointsToActivity < ActiveRecord::Migration
  def change
    change_column :activities, :points, :integer, :default => 0
    change_column :activities, :percent_complete, :integer, :default => 0
  end
end
