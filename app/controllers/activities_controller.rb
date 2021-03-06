require 'csv'

class ActivitiesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_activity, only: [:show, :edit, :update, :destroy]
	before_action :owned_activity, only: [:edit, :update, :destroy]

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
    get_current_point_values(current_user)
    @activities = current_user.activities.order('id ASC')
  end

  # To display all of my completed activities
  def my_completed_activities
    @activities = Activity.where(user_id: params[:id], is_completed: true)
  end

  # Renders user details page
  def user_details
    @details = [current_user.score, current_user.level]
  end

  def get_activity_detail
    render json: current_user.activities.find(params[:id])
  end

  def start_activity
    qid = params[:id].to_i == 0 ? params[:qid] : current_user.activities.find(params[:id]).a_id
    create_quitter(qid, activity_start_time: Time.now.to_s)
    render nothing: true
  end

  # called when the user selects another activity without finishing the current activity
  def abandon_activity
    create_quitter(params[:a_id], activityAbortTime: Time.now.to_s)
    render nothing: true
  end

  def delete_activity
    current_user.activities.where(a_id: params[:id]).destroy_all
    render text: 'delete activity'
  end

	# Aborts the current activity and logs data into Quitter class for exporting
	# params: - :id: Id of the activity to abort.
  def abort_activity
    Time.zone = "America/Los_Angeles"

    @activity = current_user.activities.find_by(a_id: params[:id])
    @activity.update(abort_time: Time.now.to_s);

    last_quitter_record = current_user.quitters.recent.find_by!(activity_id: @activity.a_id)
    last_quitter_record.update(activityAbortTime: Time.new.to_s)

    render text: 'abort activity'
  end

  # Creates points table from CSV file "points.csv"
  def create_points_table
    Point.delete_all

    @constant_point_value = BONUS * 100 / ACTIVITIES.count

    ACTIVITIES.each do |activity|
      Point.create(activity_id: activity['Number'], state: 0, point_value: @constant_point_value, time_left: 0, condition: "constant points")
      Point.create(activity_id: activity['Number'], state: 0, point_value: 0, time_left: 0, condition: "control condition")
    end

    csv_text = File.read(Rails.root.join('app', 'assets', 'data', 'points.csv'))
    csv = CSV.parse(csv_text, :headers => true)

    ['points condition', 'monetary condition'].each do |condition|
      values = csv.map { |row| "(#{row['activity_id']}, #{row['state_id']}, #{row['point_value'].to_i}, '#{condition}')" }
      ActiveRecord::Base.connection.execute(%Q{INSERT INTO points (activity_id, state, point_value, condition) VALUES #{values.join(', ')}})
    end
  end

	# Sets default activities for an experimentee.
	# Pulls admin's todo list and initializes experimentee's account with Admin's to-do list
	# params - :current_user: The user id of the current user initializing their to-do list.
  def set_default_activities
    current_user.activities.destroy_all

    condition_names = ['monetary condition', 'length heuristic','control condition']
    #condition_names = ['control condition', 'monetary condition', 'points condition', 'constant points', 'advice', 'forced']
    #condition_nr = current_user.id % 6
    #condition_names = ['monetary condition', 'advice', 'forced']
    #condition_names = ['monetary condition x 10','advice','forced']
    condition_nr = current_user.id % condition_names.length

    current_user.update(experimental_condition: condition_names[condition_nr])

    ACTIVITIES.each do |activity|
      current_user.activities.create(
        content: activity['Name'],
        duration: activity['Duration'].to_f,
        code: SecureRandom.urlsafe_base64(8),
        a_id: activity['Number']
      )
    end

    points = get_current_point_values(current_user)

    current_user.activities.each do |activity|
      activity.update_column(:points, points[activity.a_id - 1])
    end

    redirect_to my_activities_activity_path(current_user)
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
    # FORMAT: [activities completed] i [User Id] d [User quit] q [user Experimental condition]
  def generate_code
    @user_id = current_user.id
    #@activities = Activity.where(:user_id => @user_id)
    @activities = current_user.activities.order('a_id ASC')      
      
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

    if admin = User.find_by(user_name: "Admin")
      admin.update(is_admin: true)
      create_points_table
    end

    render text: 'admin enabled'
  end

	private

	def activity_params
	  params.require(:activity).permit(:image, :content, :points, :duration, :code, :a_id)
	end

  def set_activity
    @activity = Activity.find(params[:id])
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

  def create_quitter(question_id, options)
    Quitter.create(options.merge(user_id: current_user.id, activity_id: question_id))
  end
end
