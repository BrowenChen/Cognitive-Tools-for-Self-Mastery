class DropFkContraintForActivityIdOnPoints < ActiveRecord::Migration
  def change
    remove_foreign_key :points, :activity
  end
end
