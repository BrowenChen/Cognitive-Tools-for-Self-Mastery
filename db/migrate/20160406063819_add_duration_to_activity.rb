class AddDurationToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :duration, :float, :default => 0
  end
end
