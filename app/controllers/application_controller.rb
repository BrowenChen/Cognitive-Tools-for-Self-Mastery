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
end
