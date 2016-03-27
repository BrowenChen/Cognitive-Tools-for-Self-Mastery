class AddLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :level, :int, default: 1 
  end
end
