class AddTimeCompletedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :time_completed, :string, :default => "Not Completed"
  end
end
