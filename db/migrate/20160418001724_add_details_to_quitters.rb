class AddDetailsToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :user_id, :integer
    add_column :quitters, :time_quit, :datetime
  end
end
