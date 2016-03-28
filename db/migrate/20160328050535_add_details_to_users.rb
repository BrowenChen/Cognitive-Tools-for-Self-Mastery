class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :points, :decimal
    add_column :users, :experiment_state, :string
  end
end
