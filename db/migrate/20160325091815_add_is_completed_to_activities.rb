class AddIsCompletedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_completed, :boolean, default: false
  end
end
