class AddFinishActivitiesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :finished_all_activities, :boolean, default: false
  end
end
