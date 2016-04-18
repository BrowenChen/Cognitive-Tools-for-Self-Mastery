class AddAidToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :a_id, :integer, :default => 1
  end
end
