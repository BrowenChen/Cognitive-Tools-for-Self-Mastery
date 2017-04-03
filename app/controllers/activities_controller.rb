class ActivitiesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_activity, only: [:show, :edit, :update, :destroy]
	before_action :owned_activity, only: [:edit, :update, :destroy]

  # Class variables
  @@bonus = 20 #dollars
  @@adminUser = User.find_by(user_name: "Admin")
  @@deadline = DateTime.parse('June 19th 2016 11:59:59 PM')

  #Class variables used in timesteps
  @@time_step = 8 #minutes
  @@total_time = 7*24*60/@@time_step #total nr of time steps from beginning of experiment to deadline

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_token

	def index
	  @activities = Activity.all
	  @users = User.all
	end

	def new
	  @activity = current_user.activities.build
	end

	# Create an activity by an Admin using "New Activity" form. Not used b/c
	# Activities are imported via CSV.
	def create
	  @activity = current_user.activities.build(activity_params)

	  if @activity.save
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
	end

	def destroy
	  Activity.find(params[:id]).destroy
	  redirect_to activities_path
	end

  # To display all of my activities
  def my_activities
    set_current_point_values(current_user)
    @activities = current_user.activities
  end

  # To display all of my completed activities
  def my_completed_activities
    @activities = Activity.where(user_id: params[:id], is_completed: true)
  end

  # Renders user details page
  def user_details
    @details = [current_user.score, current_user.level]
  end

  def finish_activity
    @activity_id = params[:activity_id]
    @user = User.find(params[:user_id])
    @activity = @user.activities.find_by(a_id: params[:activity_id])
    @user.update(score: @user.score + @activity.points)
    @activity.update(activity_time_completed: Time.now);
    @activity.update(is_completed: true);

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id: @activity_id, user_id: params[:user_id], activity_finish_time: nil, activityAbortTime: nil)
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
    render json: current_user.activities.find(params[:id])
  end

  def start_activity
    qid = params[:id].to_i == 0 ? params[:qid] : current_user.activities.find(params[:id]).a_id
    Quitter.create(user_id: current_user.id, activity_id: qid, activity_start_time: Time.new.to_s)
    render nothing: true
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

    @activity = Activity.find_by(a_id: params[:id])
    @activity.update(abort_time: Time.now.to_s);

    if Quitter.exists?(activity_id: params[:id], user_id: current_user.id, activityAbortTime: nil, activity_finish_time: nil)
      quitter = Quitter.find_by! activity_id: params[:id], user_id: current_user.id, activity_finish_time: nil
      puts "Activity exists with the user."
      quitter.update(activityAbortTime: Time.new.to_s)

    else
      puts "Create a new Quitter Record for activity abort time.  "
      Quitter.create(user_id: current_user.id, activity_id: activity.a_id, activityAbortTime: Time.now.to_s)
    end

    render text: 'abort activity'
  end

  #Loading function to load in csv to-do list only when Admin account is enabled.
	# Uses CSV data to create activities that all experimentees will use into their accounts
	# When "initialize to-do" button is pressed.
	#params - :adminUser: ID of admin user to check if Admin user exists.
  def load_todo_from_csv(adminUser)
  	require 'csv'

  	puts "Loading to-do from csv"
  	puts "Checking if previous activities exist, and deleting them"

  	if Activity.where(:user_id => adminUser.id).exists?
      puts "admin User exists"
  		Activity.where(:user_id => adminUser.id).destroy_all
  		puts "destorying all previous activiteis"
  	end

  	csv_text = File.read(File.join(Rails.root, 'app/assets/data/todo_list.csv'))
  	csv = CSV.parse(csv_text, :headers => true)

  	puts "Random code word for CSV to-dos"
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

  #Creates points table from CSV file "points.csv"
  def create_points_table
    require 'csv'
    Point.destroy_all

    @@adminUser = User.find_by(user_name: "Admin")
    @nr_tasks = Activity.where(user_id: @@adminUser.id).count
    @constant_point_value = @@bonus * 100 / @nr_tasks

    activities = Activity.all
  	activities.each do |record|
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
	# Pulls admin's todo list and initializes experimentee's account with Admin's to-do list
	# params - :current_user: The user id of the current user initializing their to-do list.
  def set_default_activities
    @time_step = 8 #minutes
    @total_time = 7*24*60/@time_step #total nr of time steps from beginning of experiment to deadline


    @admin_id = User.where(:user_name => "Admin")
    if Activity.where(:user_id => params[:current_user]).exists?

      # Quick FIX. user id is
      if params[:current_user] != '1'
        Activity.where(:user_id => params[:current_user]).destroy_all
      end
    end

    @control_condition = "control condition"
    @monetary_condition = "monetary condition"
    @points_condition = "points condition"
    @control_condition2 = "constant points"

    experimental_condition = [@control_condition, @control_condition2, @points_condition, @monetary_condition]
    #experimental_condition = [@control_condition] #only for piloting purposes

    #@random_condition = experimental_condition.shuffle.sample
    @random_condition = "control condition"

    User.find(current_user.id).update(:experimental_condition => @random_condition)

    @admin_id = User.where(:user_name => "Admin")
    @activities = Activity.where(:user_id => @admin_id)

    #Add if user is not Admin.
    if params[:current_user] != '1'
        @activities.each do |record|
          @unique_code = current_user.user_name.chars.first + record.code + current_user.user_name.chars.last
          Activity.new(content: record.content, user_id: params[:current_user], duration: record.duration, code: @unique_code, a_id: record.a_id).save
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
  	activities = current_user.activities
  	condition = current_user.experimental_condition
  	@current_point_values = []

    if condition == "constant points"
      @nr_tasks = Activity.where(user_id: @@adminUser.id).count
      @constant_point_value = @@bonus * 100 / @nr_tasks
      activities.each do |activity|
        @current_point_values.push(@constant_point_value)
      end
      @current_point_values.push(0)

    else
  	  activities.each do |activity|
  	    @nr_points = Point.where(activity_id: activity.a_id, state: get_state_id, condition: condition)[0]

        if @nr_points
          @nr_points = @nr_points.point_value
  	    end

        @current_point_values[activity.a_id-1]=@nr_points
  	  end

      p = Point.where(activity_id: 6, state: 0, condition: 'points condition')
      @current_point_values.push(p[0]['point_value']) if p.any?
    end

  	@current_point_values
  end

	# Gets the state_id for the current user, which is computed based off number of completed
	# activities this user has done.
  def get_state_id
    @nr_activities = current_user.activities.count
  	@completed_activities = current_user.activities.where(is_completed: true)

  	state_id = 0

    if @completed_activities.length != 0
    	@completed_activities.each do |activity|
    		position = activity.a_id
    		state_id += 2 ** (@nr_activities - position)
    	end
    end

  	state_id
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

    @score = "b"

    #Setting the activites Score
    @activities.each do |record|
      if record.is_completed
        @score = @score + "1"
      else
        @score = @score + "0"
      end
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

  def by_code
    render json: current_user.activities.find_by(code: params[:id])
  end

  # TODO:
  def enable_admin
    return render(text: 'Wrong Code') if params[:code] != '9128'

    if @adminUser = User.find_by(user_name: "Admin")
      @adminUser.update(is_admin: true)
      load_todo_from_csv(@adminUser)
    end

    render text: 'admin enabled'
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

  def bad_token
    flash[:warning] = "Session expired"
    redirect_to root_path
  end
end
