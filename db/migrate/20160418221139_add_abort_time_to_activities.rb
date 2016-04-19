class AddAbortTimeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :abort_time, :datetime
  end
end
