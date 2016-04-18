class CreateQuitters < ActiveRecord::Migration
  def change
    create_table :quitters do |t|

      t.timestamps null: false
    end
  end
end
