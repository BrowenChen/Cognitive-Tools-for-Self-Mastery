class RemoveTimeCompletedFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :time_completed
  end
end
