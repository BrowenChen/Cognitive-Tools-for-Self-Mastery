class CreatePoints < ActiveRecord::Migration
  def change 
    create_table :points do |t|
      t.references :activity, index: true, foreign_key: true
      t.timestamps null: false
      t.integer :state
      t.integer :point_value
      t.float :time_left
      t.string :condition    
    end
  end
end