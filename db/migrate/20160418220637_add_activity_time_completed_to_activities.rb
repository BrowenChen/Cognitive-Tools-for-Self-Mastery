class AddActivityTimeCompletedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :activity_time_completed, :datetime
  end
end
