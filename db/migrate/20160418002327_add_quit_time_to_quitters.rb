class AddQuitTimeToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :quit_time, :time
  end
end
