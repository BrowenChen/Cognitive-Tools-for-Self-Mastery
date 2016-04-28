class AddAbortActivityToQuitter < ActiveRecord::Migration
  def change
    add_column :quitters, :activityAbortTime, :string
  end
end
