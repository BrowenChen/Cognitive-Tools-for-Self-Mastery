class AddTimeToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :time_quit, :string
  end
end
