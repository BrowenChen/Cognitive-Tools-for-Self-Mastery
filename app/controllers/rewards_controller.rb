class RewardsController < ApplicationController

	def quit_experiment
		user = User.find_by(id: current_user.id)
		user.is_active = false
		user.save
		Time.zone = "America/Los_Angeles"
		#Check if Quitter with current user id already exists in db
		Quitter.create(user_id: current_user.id, time_quit: Time.new.to_s)
		sign_out current_user
		redirect_to root_path
	end


	#Starting tetris
	def start_tetris
		#Check if Quitter record with current_user.id exists
		# If so, take that, update tetris_time to current time
		# if not, create a new Quitter record with tetris_time as current time
	end
end
