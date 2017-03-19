class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :activity, index: true, foreign_key: true
      t.text :answer
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
