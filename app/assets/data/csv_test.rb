puts 'test'


   

ActiveRecord::Base.connection.create_table :levels, :force => true do |t|
    t.string   "Name"
    t.string "Required Score"
    t.integer  "Level"
end 

require 'csv' 
csv_text = File.read('app/assets/data/todo_lis.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
    puts row
end