class AddUserIdToActivities < ActiveRecord::Migration
  def change
    add_reference :activities, :user, index: true, foreign_key: true
  end
end
