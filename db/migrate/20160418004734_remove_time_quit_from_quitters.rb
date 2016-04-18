class RemoveTimeQuitFromQuitters < ActiveRecord::Migration
  def change
    remove_column :quitters, :time_quit, :time
  end
end
