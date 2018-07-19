class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
  	if !resource.is_active
  		sign_out resource
  		flash[:error] = "You have quit the experiment!"
  		root_path
  	else
  		super
  	end
  end

  private

	# Sets up current point values for current user's activity points.
	# This is updated with state_id, based off of how many activities a user has completed.
	# This function is called whenever updates occur, to update point values of current user
	# params - :current_user: User model of the current logged in user.
  def get_current_point_values(user)
    admin = User.find_by!(user_name: 'Admin')
  	activities = user.activities.order('a_id ASC')
  	@current_point_values = []

    if user.constant_points?
      constant_point_value = BONUS * 100 / ACTIVITIES.count
      @current_point_values = activities.map { |activity| constant_point_value }
      @current_point_values.push(0)

    elsif user.length_heuristic?
      total_duration = activities.sum(:duration)
      per_unit_duration = (BONUS * 100) / activities.sum(:duration)
      @current_point_values = activities.map { |activity| (per_unit_duration * activity.duration).floor }
      @current_point_values.pop
      @current_point_values.push(BONUS * 100 - @current_point_values.sum)
      @current_point_values.push(0)

    else
  	  @current_point_values = activities.map do |activity|
        condition = user.experimental_condition
        condition = 'points condition' if %w[advice forced].include?(condition)
        condition = 'monetary condition' if condition == 'monetary condition x 10'

  	    if point = Point.find_by(activity_id: activity.a_id, state: get_state_id, condition: condition)
          point.point_value
        end
  	  end

      if point = Point.find_by(activity_id: 11, state: 0, condition: 'points condition')
        @current_point_values.push(point.point_value)
      end
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
end
