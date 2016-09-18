class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: [:show, :edit, :update, :destroy]  
  #ensure only you have access to modify your posts
  before_action :owned_activity, only: [:edit, :update, :destroy] 

    # Class variables
    # @@constant_point_value = 5
  @@bonus = 20 #dollars
  @@adminUser = User.find_by(user_name: "Admin")
  #@@nr_tasks = Activity.where(user_id: @@adminUser.id).count
    #@@constant_point_value = @@bonus * 100 / @@nr_tasks  
    #@@deadline = DateTime.parse('June 19th 2016 11:59:59 PM')
  @@deadline = 2.hours.from_now
  puts @@deadline
  puts "DEADLINE"
    #
    #Class variables used in timesteps
  @@time_step = 8 #minutes
  @@total_time = 7*24*60/@@time_step #total nr of time steps from beginning of experiment to deadline  

  def index
	@activities = Activity.all
	@users = User.all
  end

  def new
	  #@activity = Activity.new
	@activity = current_user.activities.build
  end
	
  def create
	@activity = current_user.activities.build(activity_params)

	if @activity.save
	  puts "CREATED ACTIVITY" 
	  flash[:success] = "Your activity has been created!"
	  redirect_to activities_path
	else
	  flash[:alert]  = "Your new activity couldn't be created!"
	  render :new
	end
  end

  def show
      set_current_point_values(current_user)
	@activity = Activity.find(params[:id])
  end

  def edit  
  end

  def update  
  	if @activity.update(activity_params)
      flash[:success] = "Activity updated."
      redirect_to activities_path  
    else
      flash.now[:alert] = "Update failed.  Please check the form."
      render :edit
    end      		  	
  	  # redirect_to(activity_path(@activity))
  end  

  def destroy
	@activity = Activity.find(params[:id])
    @activity.destroy
	redirect_to activities_path	  
  end

  # to display all of my activities
  def my_activities
    set_current_point_values(current_user)   
    @activities = Activity.where(:user_id => params[:id])
  end

  # to display all of my completed activities
  def my_completed_activities
    @activities = Activity.where(["user_id = ? and is_completed = ?", params[:id], true])
  end


  #user details page
  def user_details
    @details = [User.find(current_user.id).score, User.find(current_user.id).level]
  end

  # Finish activity version that is a get request and takes in :act_id
  def finish_cur_activity
    puts "finish cur activity"
    @activity_id = params[:act_id]
    puts @activity_id
    puts current_user.id
    @activity = Activity.where("a_id = ? AND user_id = ?", @activity_id, current_user.id).first;
    # puts @activity.

    @user = User.find(current_user.id)
    puts @user.user_name
    # @new_score = @user.score + @activity.points 

    #Put check if user is not in control condition with no point value
    if current_user.experimental_condition != "control condition"
      @current_point_values = set_current_point_values(current_user)
      puts "Current_point values: "
      puts @current_point_values
      puts "Activity id"
      puts @activity.a_id

      @new_score = @user.score + @current_point_values[@activity.a_id-1]
      puts @new_score
      @user.update(score: @new_score)
      #update user level here
      if @user.level < 2 and @new_score >= 200 and @new_score < 600
        @user.update(level: 2)
      elsif @user.level < 3 and @new_score >= 600 and @new_score < 1200
        @user.update(level: 3)
      elsif @user.level < 4 and @new_score >= 1200 and @new_score < 2000
        @user.update(level: 4)
      elsif @user.level < 5 and @new_score >= 2000
        @user.update(level: 5)      
      else
        puts "Else case for updating levels"
      end
    end

    puts Time.now
    @activity.update(activity_time_completed: Time.now);
    @activity.update(is_completed: true);

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id:  @activity_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil)
      puts "Activity exists with the user AND THE ACTIVITY IS FINISHED."
      quitter = Quitter.find_by! activity_id: @activity_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil
      quitter.update(activity_finish_time: Time.new.to_s)
    else
      puts "This is called in the case that an activity is finished before it is started"
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activity_finish_time: Time.now.to_s)
    end 


    #Check if all activities for this user is finished
    @user_activities = Activity.where("user_id = ?", current_user.id);

    @all_finished = true
    @user_activities.each do |activity|
  	if !activity.is_completed
  		@all_finished = false
  	end

    end  

    puts @all_finished
    if @all_finished == true
	     @user.update(finished_all_activities: true)
    end 

    set_current_point_values(current_user)

    respond_to do |format|
      format.js { render js: "window.location.reload();" }  
    end
  end    

  #testing show message
  def finish_activity
    @activity_id = params[:activity_id]
    puts @activity_id
    @activity = Activity.where("a_id = ? AND user_id = ?", params[:activity_id], params[:user_id]).first;
    puts @activity.points
    @user = User.find(params[:user_id])
    puts @user.user_name
    @new_score = @user.score + @activity.points 
    puts @new_score
    @user.update(score: @new_score)
    puts Time.now
    @activity.update(activity_time_completed: Time.now);
    @activity.update(is_completed: true);

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id:  @activity_id, user_id: params[:user_id], activity_finish_time: nil, activityAbortTime: nil)
      puts "Activity exists with the user AND THE ACTIVITY IS FINISHED."
      quitter = Quitter.find_by! activity_id: @activity_id, user_id: params[:user_id], activity_finish_time: nil, activityAbortTime: nil
      quitter.update(activity_finish_time: Time.new.to_s)
    else
      puts "This is called in the case that an activity is finished before it is started"
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activity_finish_time: Time.now.to_s)
    end 

    respond_to do |format|
      format.js { render js: "window.location.reload();" }  
    end
  end


  def get_activity_detail
    # @activity = Activity.where("a_id = ?", params[:id]);
    # puts Activity.where("a_id = ? AND user_id = ?", params[:id], current_user.id).first
    @activity = Activity.where("a_id = ? AND user_id = ?", params[:id], current_user.id);
    puts "Getting activity detail"
    @act_duration = @activity.first.duration
    @act_code = @activity.first.code

    # if Quitter.exists?(activity_id: params[:id], user_id: current_user.id)
    #   puts "Activity exists with the user."
    #   quitter = Quitter.find_by(activity_id: params[:id])
    #   quitter.update(activity_start_time: Time.new.to_s)
    # else
    # Quitter.create(user_id: current_user.id, activity_id: params[:id], activity_start_time: Time.new.to_s)
    # end    

    render json: @activity
  end


  def start_activity
    Quitter.create(user_id: current_user.id, activity_id: params[:id], activity_start_time: Time.new.to_s)
    render :text => "Starting activity"
  end

  def delete_activity
    @activity_id = params[:id]
    @current_user_id = current_user.id
    Activity.where("a_id = ? AND user_id = ?", @activity_id, @current_user_id).destroy_all
    render :text => "delete activity"
  end

  def abort_activity
    Time.zone = "America/Los_Angeles"
    puts Time.zone.now.to_s
    @activity_id = params[:id]
    @activity = Activity.where("a_id = ?", params[:id]).first;
    @activity.update(abort_time: Time.now.to_s);

    @activityAbort = "Activity id: " + @activity_id + " Time: " + Time.now.to_s
    puts @activityAbort

  # If activity exists that has been started and hasnt been ended or aborted
    if Quitter.exists?(activity_id: params[:id], user_id: current_user.id, activityAbortTime: nil, activity_finish_time: nil)
      quitter = Quitter.find_by! activity_id: params[:id], user_id: current_user.id, activity_finish_time: nil
      puts "Activity exists with the user."
      quitter.update(activityAbortTime: Time.new.to_s)

    else
      puts "Create a new Quitter Record for activity abort time.  "
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activityAbortTime: Time.now.to_s)
    end 
    
    # puts @activity
    render :text => "abort activity"
  end

  #Loading function to load in csv todo list only when Admin account is enabled.
  def load_todo_from_csv(adminUser)
  	require 'csv'

  	puts "Loading todo from csv"
  	puts "Checking if previous activities exist, and deleting them" 

  	if Activity.where(:user_id => adminUser.id).exists?
      puts "admin User exists"
  		Activity.where(:user_id => adminUser.id).destroy_all
  		puts "destorying all previous activiteis" 
  	end

  	csv_text = File.read('app/assets/data/todo_list.csv')
  	csv = CSV.parse(csv_text, :headers => true)

  	puts "Random code word for CSV todos" 
  	csv.each do |row|
  		code_word = (0...8).map { (65 + rand(26)).chr }.join
  		puts code_word
  	    puts adminUser.id
        puts row["Name"]
        puts row["Points"].to_i
        puts Float(row["Duration"])
        puts code_word
        puts row["Number"]
  		Activity.new(content: row["Name"], user_id: @adminUser.id, duration: Float(row["Duration"]), code: code_word, a_id: row["Number"]).save

        puts "created new activity"
    end

    create_points_table
    load_break_points
    set_current_point_values(current_user)

  end

  def enable_admin
    puts "enabling admin for current user"
    puts params[:code].to_s	
    @adminCode = '9128'
    puts @adminCode.eql?(params[:code])
    if params[:code].eql?(@adminCode)
    	if User.exists?(user_name: "Admin")
    		puts "Admin Account exists, setting admin privleges"
    		@adminUser = User.find_by(user_name: "Admin")
    		@adminUser.update(is_admin: true)
    		load_todo_from_csv(@adminUser)
    	else
    		puts "No admin account"
    	end

    	render :text => "admin enabled"
    else
        render :text => "Wrong Code" 
    end
  end

  #Create points table from CSV file TODO:
  def create_points_table
    require 'csv'
    puts "CREATING POINTS TABLE"
    Point.destroy_all
    puts "Destroying all previous points"

    @nr_tasks = Activity.where(user_id: @@adminUser.id).count
    @constant_point_value = @@bonus * 100 / @nr_tasks  
  	
    activities = Activity.all
  	activities.each do |record|
  		puts record
  		#TODO: 
        Point.new(activity_id: record.a_id, state: 0, point_value: @constant_point_value, time_left: 0, condition: "constant points").save
  		Point.new(activity_id: record.a_id, state: 0, point_value: 0, time_left: 0, condition: "control condition").save
  	end

    #points csv file shortened
  	csv_text = File.read('app/assets/data/points.csv')
    #compressed all points file.  
  	#csv_text = File.read('app/assets/data/compressed_points.csv')
  	csv = CSV.parse(csv_text, :headers => true)
  	#id=0
  	csv.each do |row|
  		#TODO:
        puts "Point value!!!" 
        puts row["point_value"]
  		Point.new(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: row["time_step"].to_i, condition: "points condition").save
        Point.new(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i/10, time_left: row["time_step"].to_i, condition: "monetary condition").save
  	end
  end

  def load_break_points
    #Clear old point entries for break activit
    puts "Load_break points function" 
    require 'csv'

    @total_time = @@total_time
    csv_text = File.read('app/assets/data/compressed_break_points.csv')

    csv = CSV.parse(csv_text, :headers => true)
    #id=0

    #debugging logs
    puts "Time step from csv"
    puts csv[0]["time_step"]
    puts @total_time
    puts @total_time-csv[0]["time_step"].to_i+1

    #break_points csv
    csv.each do |row|
        Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "points condition")

        Point.create(activity_id: row["activity_id"].to_i, state: row["state_id"].to_i, point_value: row["point_value"].to_i, time_left: @total_time-row["time_step"].to_i+1, condition: "monetary condition")
    end

  end


  def set_default_activities
    puts "setting default activites"
    puts params[:current_user]

    puts "Delete user's activities"

    @time_step = 8 #minutes
    @total_time = 7*24*60/@time_step #total nr of time steps from beginning of experiment to deadline  
       
    if Activity.where(:user_id => params[:current_user]).exists?
      Activity.where(:user_id => params[:current_user]).destroy_all
      puts "destroying all previous activities"
    end

    puts "Also randomizing experimental condition"

    @control_condition = "control condition"
    @monetary_condition = "monetary condition"
    @points_condition = "points condition"
    @control_condition2 = "constant points"

    experimental_condition = [@control_condition, @control_condition2, @points_condition, @monetary_condition]
   

    @random_condition = experimental_condition.shuffle.sample
    
    puts "picking random condition"
    puts @random_condition
    User.find(current_user.id).update(:experimental_condition => @random_condition)
    
    puts "saving user's random condition"

    @admin_id = User.where(:user_name => "Admin")
    @activities = Activity.where(:user_id => @admin_id)
    puts @activities.count

    # Activity.destroy_all(:user_id => params[:current_user])
    @activities.each do |record|
	    puts "TESTING UNIQUE CODE" 

      puts record
      puts current_user.user_name
      @unique_code = current_user.user_name.chars.first + record.code + current_user.user_name.chars.last
      puts @unique_code

      #Generate random code based on current user's username
      # if @random_condition == "constant points" 
	     #   points = 5
      # else
	     #   points = record.points
      # end
      # Activity.new(content: record.content, user_id: params[:current_user], points: points, duration: record.duration, code: @unique_code, a_id: record.a_id).save
          #Generate random code based on current user's username        
         #nr_points = Point.where(activity_id: record.id, time_left: @total_time, state: 0, condition: @random_condition)[0].point_value
      
      #nr_points = Point.where(activity_id: record.a_id, state: 0, condition: @random_condition)[0].point_value
      Activity.new(content: record.content, user_id: params[:current_user], duration: record.duration, code: @unique_code, a_id: record.a_id).save
      
      puts "created new record"
      puts "set_current_point_values"  
      set_current_point_values(current_user)  
    end    
    redirect_to root_path

  end


  def set_current_point_values(current_user)
    puts "SETTING CURRENT POINTS VALUE"
  	activities = Activity.where(user_id: current_user.id)
    puts "Number of activities"
    puts activities.count
  	condition = User.find(current_user.id).experimental_condition
  	@current_point_values = Array.new

  	activities.each do |activity|
  	  @nr_points = Point.where(activity_id: activity.a_id, state: get_state_id, condition: condition)[0]
      puts "Point value is "
      
      if @nr_points != nil
        puts "Number points is not nil"
        puts @nr_points.point_value
        @nr_points = @nr_points.point_value
  	  end

      @current_point_values.push(@nr_points)
  	end
    puts "Current Point values"
  	puts @current_point_values
  	return @current_point_values
  end 

  def update_score_and_points(current_user)
    require 'rufus-scheduler'
    scheduler = Rufus::Scheduler.new

    scheduler.every '8m' do
        ActiveRecord::Base.connection_pool.with_connection do
            set_current_point_values(current_user)
            #check if user is currently working on one of the tasks
            user_actions=Quitter.where(user_id: current_user.id)

            unless user_actions.empty?
                last_action = user_actions[-1]
                puts "in scheduler"
                working = last_action.activity_start_time != nil && last_action.activityAbortTime == nil
                if working
                    puts "User was working"
                else 
                    puts "User was slacking"
                end

                unless working
                    puts "Updating score according to break points"
                    #puts "State ID: #{get_state_id}"
                    #puts "Remaining Time: #{get_remaining_time_steps}"

                    break_point = Point.where(state: get_state_id, activity_id: 0, time_left: get_remaining_time_steps)[-1].point_value
                    user_record = User.find(current_user.id)
                    new_score = user_record.score + break_point

                    puts "Break Point #{break_point}"
                    user_record.update(score: new_score)
                    puts "Users score has been updated"
                    my_activities
                end
            end
        end
    end
  end

  def get_state_id
  	#get ID's of completed activities
  	puts "In get state id"
    @nr_activities = Activity.where(user_id: current_user.id).count()
  	puts @nr_activities

  	@completed_activities = Activity.where(user_id: current_user.id, is_completed: true)

  	state_id = 0

    puts @completed_activities
    if @completed_activities != nil 
      puts "completed activities is not nil"
    	@completed_activities.each do |activity|
    		position = activity.a_id
    		state_id += 2 ** (@nr_activities - position)
    	end
    end

    puts "The state id is"
    puts state_id

  	return state_id
  end


  def export_data
    # Function to render all data from activities and users for the experimenter 
    @quitters = Quitter.all
    render json: @quitters
    # render :text => "Rendering all data from database for export "
  end

  def export_user_data
    @users = User.all
    render json: @users
  end

  # Code generation for when users claim their payment
  # FORMAT: [activities completed] 9 [User Id] 9 [User quit] 9 [user Experimental condition]
  def generate_code
    @user_id = current_user.id
    @activities = Activity.where(:user_id => @user_id)
    @user_experimental_condition = current_user.experimental_condition
    @user_score = current_user.score
    @user_quit = current_user.is_active

    puts "Is user acitive"
    puts @user_quit
    puts @user_id
    puts @user_experimental_condition
    puts @user_score

    @score = "b"

    #Setting the activites Score
    @activities.each do |record|
      puts record
      if record.is_completed
        @score = @score + "1"
      else 
        @score = @score + "0"
      end
      puts @score
    end      
    @score = @score + "i"

    # User ID
    @score += @user_id.to_s
    @score = @score + "d"

    #user quit
    if @user_quit
      @score += "1"
    else
      @score += "0"
    end
    @score = @score + "q"

    #User experimental Condition
    if @user_experimental_condition == "Initial condition"
      @score += "1"
    else
      @score += "0"
    end
    @score += "e"
    puts @score
    
    render json: @score.to_json
  end

	private 

	def activity_params
	  params.require(:activity).permit(:image, :content, :points, :duration, :code, :a_id)
	end

  def set_activity
    @activity = Activity.find(params[:id])
    puts @activity[:duration]
    puts "The activities of this user"
  end	

  def owned_activity 
    unless current_user == @activity.user
      flash[:alert] = "That post doesn't belong to you!"
      redirect_to root_path  
    end    
  end

  # # GET /posts
  # # GET /posts.json
  # def index
  #   @posts = Post.all
  # end

  # # GET /posts/1
  # # GET /posts/1.json
  # def show
  # end

  # # GET /posts/new
  # def new
  #   @post = Post.new
  # end

  # # GET /posts/1/edit
  # def edit
  # end

  # # POST /posts
  # # POST /posts.json
  # def create
  #   @post = Post.new(post_params)

  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to @post, notice: 'Post was successfully created.' }
  #       format.json { render :show, status: :created, location: @post }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /posts/1
  # # PATCH/PUT /posts/1.json
  # def update
  #   respond_to do |format|
  #     if @post.update(post_params)
  #       format.html { redirect_to @post, notice: 'Post was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @post }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /posts/1
  # # DELETE /posts/1.json
  # def destroy
  #   @post.destroy
  #   respond_to do |format|
  #     format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_post
  #     @post = Post.find(params[:id])
  #   end

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def post_params
  #     params.fetch(:post, {})
  #   end	
end
