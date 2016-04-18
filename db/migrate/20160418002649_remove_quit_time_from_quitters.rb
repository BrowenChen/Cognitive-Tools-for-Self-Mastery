class RemoveQuitTimeFromQuitters < ActiveRecord::Migration
  def change
    remove_column :quitters, :quit_time, :time
  end
end
