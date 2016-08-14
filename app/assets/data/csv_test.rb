puts 'test'


require 'csv'    

ActiveRecord::Base.connection.create_table :levels, :force => true do |t|
    t.string   "Name"
    t.string "Required Score"
    t.integer  "Level"
end 


csv_text = File.read('app/assets/data/levels_for_procrastination_experiment1.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
    puts row
end