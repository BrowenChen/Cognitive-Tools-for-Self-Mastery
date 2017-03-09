class ActivitiesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_activity, only: [:show, :edit, :update, :destroy]
  #ensure only you have access to modify your posts
	before_action :owned_activity, only: [:edit, :update, :destroy]

  # Class variables
  @@bonus = 20 #dollars
  @@adminUser = User.find_by(user_name: "Admin")
  @@deadline = DateTime.parse('June 19th 2016 11:59:59 PM')

  #Class variables used in timesteps
  @@time_step = 8 #minutes
  @@total_time = 7*24*60/@@time_step #total nr of time steps from beginning of experiment to deadline

	# Main route for Todo app.
	def index
	  @activities = Activity.all
	  @users = User.all
	end

	def new
	  #@activity = Activity.new
	  @activity = current_user.activities.build
	end

	# Create an activity by an Admin using "New Activity" form. Not used b/c
	# Activities are imported via CSV.
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

  # To display all of my activities
  def my_activities
    set_current_point_values(current_user)
    @activities = Activity.where(:user_id => params[:id])
  end

  # To display all of my completed activities
  def my_completed_activities
    @activities = Activity.where(["user_id = ? and is_completed = ?", params[:id], true])
  end


  # Renders user details page
  def user_details
    @details = [User.find(current_user.id).score, User.find(current_user.id).level]
  end

  # Finish activity version that is a get request and takes in :act_id
	# Queries the database to update completion details and updates User's score + level
	# Params: - :act_id: Passed in through API route for activity id to update
  def finish_cur_activity
    puts "finish cur activity"
    @activity_id = params[:act_id].to_i
    puts @activity_id
    puts current_user.id
    @activity = Activity.where("a_id = ? AND user_id = ?", @activity_id, current_user.id).first;

    @user = User.find(current_user.id)
    puts @user.user_name
    puts current_user.experimental_condition
    puts "User's experimental condition"
    
    #Put check if user is not in control condition with no point value
    if current_user.experimental_condition != "control condition"
      @current_point_values = set_current_point_values(current_user)
      puts "Current_point values: "
      puts @current_point_values
      puts "Activity id"
      #puts @activity.a_id
      puts @activity_id

      @new_score = @user.score + @current_point_values[@activity_id-1]
      puts @new_score
      @user.update(score: @new_score)
      #update user level here
      if @user.level < 2 and @new_score >= 150 and @new_score < 500
        @user.update(level: 2)
      elsif @user.level < 3 and @new_score >= 500 and @new_score < 1000
        @user.update(level: 3)
      elsif @user.level < 4 and @new_score >= 1000 and @new_score < 1500
        @user.update(level: 4)
      elsif @user.level < 5 and @new_score >= 1500
        @user.update(level: 5)
      else
        puts "Else case for updating levels"
      end
    end

    puts Time.now
    if (@activity)  
        @activity.update(activity_time_completed: Time.now);
        @activity.update(is_completed: true);
    end

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
		# Updates all points for this user
    set_current_point_values(current_user)

    respond_to do |format|
      format.js { render js: "window.location.reload();" }
    end
  end

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
    @activity = Activity.where("a_id = ? AND user_id = ?", params[:id], current_user.id);
    puts "Getting activity detail"
    @act_duration = @activity.first.duration
    @act_code = @activity.first.code
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

	# Aborts the current activity and logs data into Quitter class for exporting
	# params: - :id: Id of the activity to abort.
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
	# Uses CSV data to create activities that all experimentees will use into their accounts
	# When "initialize todo" button is pressed.
	#params - :adminUser: ID of admin user to check if Admin user exists.
  def load_todo_from_csv(adminUser)
  	require 'csv'

  	puts "Loading todo from csv"
  	puts "Checking if previous activities exist, and deleting them"

  	if Activity.where(:user_id => adminUser.id).exists?
      puts "admin User exists"
  		Activity.where(:user_id => adminUser.id).destroy_all
  		puts "destorying all previous activiteis"
  	end

  	csv_text = File.read(File.join(Rails.root, 'app/assets/data/todo_list.csv'))
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
    set_current_point_values(current_user)
  end

	# Enables the user account with name "Admin" to have admin priviledges.
	# Code passed in through enable_admin/:code route, and checked if it is the correct code.
	# params - :code: Code passed in through API route.
  def enable_admin
    puts "enabling admin for current user"
    puts params[:code].to_s
		# Set Arbitrary admin code. enable_admin/[admin code]
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

  #Creates points table from CSV file "points.csv"
  def create_points_table
    require 'csv'
    puts "CREATING POINTS TABLE"
    Point.destroy_all
    puts "Destroying all previous points"

    @@adminUser = User.find_by(user_name: "Admin")
    @nr_tasks = Activity.where(user_id: @@adminUser.id).count
    @constant_point_value = @@bonus * 100 / @nr_tasks

    activities = Activity.all
  	activities.each do |record|
  		puts record
      Point.new(activity_id: record.a_id, state: 0, point_value: @constant_point_value, time_left: 0, condition: "constant points").save
  		Point.new(activity_id: record.a_id, state: 0, point_value: 0, time_left: 0, condition: "control condition").save
  	end

  	csv_text = File.read(File.join(Rails.root, 'app/assets/data/points.csv'))
  	csv = CSV.parse(csv_text, :headers => true)

  	csv.each do |row|
  		Point.new(activity_id: row["activity_id"], state: row["state_id"], point_value: row["point_value"], time_left: row["time_step"], condition: "points condition").save
      Point.new(activity_id: row["activity_id"], state: row["state_id"], point_value: row["point_value"].to_i/10, time_left: row["time_step"], condition: "monetary condition").save
  	end
  end

	# Sets default activities for an experimentee.
	# Pulls admin's todo list and initializes experimentee's account with Admin's todo list
	# params - :current_user: The user id of the current user initializing their todo list.
  def set_default_activities
    puts "setting default activites"
    puts params[:current_user]
    puts "Delete user's activities"

    @time_step = 8 #minutes
    @total_time = 7*24*60/@time_step #total nr of time steps from beginning of experiment to deadline


    @admin_id = User.where(:user_name => "Admin")
    if Activity.where(:user_id => params[:current_user]).exists?
      # Dont delete admin's activities
      puts "Dont delete addmin's activities"
      puts params[:current_user]

      # Quick FIX. user id is 
      if params[:current_user] != '1'
        Activity.where(:user_id => params[:current_user]).destroy_all
        puts "destroying all previous activities"
      end
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

    #Add if user is not Admin.
    if params[:current_user] != '1'
        @activities.each do |record|
	        puts "Unique code for activity: "
            puts record
            puts current_user.user_name
            @unique_code = current_user.user_name.chars.first + record.code + current_user.user_name.chars.last
            puts @unique_code
            Activity.new(content: record.content, user_id: params[:current_user], duration: record.duration, code: @unique_code, a_id: record.a_id).save

            puts "created new record"
            puts "set_current_point_values"
            set_current_point_values(current_user)
        end
    end
    redirect_to root_path
  end

	# Sets up current point values for current user's activity points.
	# This is updated with state_id, based off of how many activities a user has completed.
	# This function is called whenever updates occur, to update point values of current user
	# params - :current_user: User model of the current logged in user.
  def set_current_point_values(current_user)
    puts "**Setting Current Point values**"
  	activities = Activity.where(user_id: current_user.id)
    puts "Number of activities"
    puts activities.count
  	condition = User.find(current_user.id).experimental_condition
  	@current_point_values = Array.new


    puts "User's condition is: "
    puts condition
    
    if condition == "constant points"
        puts "pushing constant points into current_point_values array"
        @nr_tasks = Activity.where(user_id: @@adminUser.id).count
        @constant_point_value = @@bonus * 100 / @nr_tasks
        activities.each do |activity|
            @current_point_values.push(@constant_point_value)
        end
        @current_point_values.push(0)
    else
  	    activities.each do |activity|
  	        @nr_points = Point.where(activity_id: activity.a_id, state: get_state_id, condition: condition)[0]
            puts "Point value is: "

            if @nr_points != nil
                puts "Checked that nr_points is not nil"
                puts @nr_points.point_value
                @nr_points = @nr_points.point_value
  	        end

            @current_point_values[activity.a_id-1]=@nr_points
  	    end
        p=Point.where(activity_id:6,state:0,condition:'points condition')
        @current_point_values.push(p[0]['point_value'])
    end

    puts "Current Point values:"
  	puts @current_point_values
  	return @current_point_values
  end

	# Gets the state_id for the current user, which is computed based off number of completed
	# activities this user has done.
  def get_state_id
  	#get ID's of completed activities
  	puts "Getting State ID of the user."
    @nr_activities = Activity.where(user_id: current_user.id).count()
  	puts @nr_activities

  	@completed_activities = Activity.where(user_id: current_user.id, is_completed: true)

  	state_id = 0
    puts @completed_activities.length
    puts "Outputting the completed activities"
    if @completed_activities.length != 0
      puts "Completed activities array isn't empty"
    	@completed_activities.each do |activity|
    		position = activity.a_id
    		state_id += 2 ** (@nr_activities - position)
    	end
    end

    puts "The state id is: "
    puts state_id

  	return state_id
  end

	# Function to render all data from activities and users for the experimenter
  def export_data
    @quitters = Quitter.all
    render json: @quitters
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

    puts "Is user acitive?"
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
end
