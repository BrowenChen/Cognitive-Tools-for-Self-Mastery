class AddTimeQuitToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :time_quit, :time
  end
end
