class AddActAbortIdToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :activity_id, :string
    add_column :quitters, :activity_start_time, :string
    add_column :quitters, :activity_finish_time, :string
  end
end
