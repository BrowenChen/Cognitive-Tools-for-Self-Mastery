class AddTetrisToQuitters < ActiveRecord::Migration
  def change
    add_column :quitters, :tetris_time, :string
  end
end
