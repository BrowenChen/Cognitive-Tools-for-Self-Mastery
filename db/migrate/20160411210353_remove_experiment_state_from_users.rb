class RemoveExperimentStateFromUsers < ActiveRecord::Migration
  def change
	remove_column :users, :experiment_state, :string
  end
end
