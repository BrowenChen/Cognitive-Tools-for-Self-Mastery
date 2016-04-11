class RemovePointsFromUser < ActiveRecord::Migration
  def change
	remove_column :users, :points, :decimal
	remove_column :users, :experimental_state, :string
  end
end
