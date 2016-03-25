class AddScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :score, :int, default: 0
  end
end
