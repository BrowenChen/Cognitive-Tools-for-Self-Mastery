class AddPercentToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :percent_complete, :decimal
  end
end
