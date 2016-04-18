class AddCodeToActivities < ActiveRecord::Migration
  def change
   add_column :activities, :code, :text, default: "xyz"
  end
end
