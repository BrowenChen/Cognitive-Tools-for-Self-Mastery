class AddExperimentalConditionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :experimental_condition, :text, default: "Initial condition"
  end
end
