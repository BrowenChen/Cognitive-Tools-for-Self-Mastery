class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.references :activity, index: true, foreign_key: true
      t.float :timestamps
      t.integer :state
      t.integer :point_value
      t.float :time_left
      t.string :condition

      t.timestamps null: false
    end
  end
end
