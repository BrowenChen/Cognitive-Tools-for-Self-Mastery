class RemoveDateTimeFromQuitters < ActiveRecord::Migration
  def change
    remove_column :quitters, :time_quit, :datetime
  end
end
