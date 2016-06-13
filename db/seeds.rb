# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def set_global_variables
    #set deadline
    Rails.application.config.deadline = DateTime.parse('June 19th 2016 11:59:59 PM')
    Rails.application.config.deadline = 3.hours.from_now
    Rails.application.config.time_step_in_min = 8
    Rails.application.config.total_time= 7*24*60/Rails.application.config.time_step_in_min
    Rails.application.config.bonus = 20
    Rails.application.config.nr_activities = Activity.where(user_id: 1).count()  
    Rails.application.config.constant_point_value = 100 * Rails.application.config.bonus /       Rails.application.config.nr_activities 
    Rails.application.config.admin_id = 1

    
end


def init_todo_list
    #initialize new todo list  
    puts "Loading Todo List"
    require 'csv' 
    csv_text = File.read('app/assets/data/todo_list.csv')

    puts csv_text  
    csv = CSV.parse(csv_text, :headers => true)

    admin_id=Rails.application.config.admin_id

    csv.each do |row|                
        code_word =  (0...8).map { (65 + rand(26)).chr }.join
        Activity.new(content: row["Name"], user_id: admin_id, duration: Float(row["Duration"]), code: code_word, a_id: row["Number"]).save
    end
end

def create_points_table
  @bonus = Rails.application.config.bonus #dollars
  @nr_tasks = Activity.where(user_id: 1).count
  @constant_point_value = Rails.application.config.constant_point_value
  @total_time = Rails.application.config.total_time

  #Enter points for the control conditions
  activities=Activity.all                              
  activities.each do |record|
      Point.create(activity_id: record.a_id, state: 0, point_value: @constant_point_value, time_left: @total_time, condition: "constant points")
      Point.create(activity_id: record.a_id, state: 0, point_value: 0, time_left: @total_time, condition: "control condition" )
  end

#Enter points for other conditions
require 'csv'
csv_text = File.read('app/assets/data/all_points.csv')
#csv_text = File.read('app/assets/data/points.csv')

csv = CSV.parse(csv_text, :headers => true)
id=0
csv.each do |row|      
    Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "points condition" )
    Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "monetary condition")
end      
end

 def load_break_points
     
     #Clear old point entries for break activity 
     #Point.where(activity_id: 0).destroy_all
     
    @total_time = Rails.application.config.total_time
    #Enter points for other conditions
    require 'csv'
     csv_text = File.read('app/assets/data/break_points.csv')
    #csv_text = File.read('app/assets/data/points.csv')

    csv = CSV.parse(csv_text, :headers => true)
    id=0
    puts csv[0]["time_step"]
    puts @total_time
    puts @total_time-csv[0]["time_step"].to_i+1
     
    csv.each do |row|      
        Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "points condition" )
        Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "monetary condition" )
    end
     
 end


set_global_variables
#init_todo_list
#create_points_table
load_break_points