class RewardsController < ApplicationController

	def quit_experiment
		user = User.find_by(id: current_user.id)
		user.is_active = false
		user.save
		puts "quitting experiment"
		puts current_user.id
		Time.zone = "America/Los_Angeles"
		#Check if Quitter with current user id already exists in db
		if Quitter.exists?(user_id: current_user.id)
			puts "User exists"
			quitter = Quitter.find_by(user_id: current_user.id)
			quitter.update(time_quit: Time.new.to_s)
		else
			Quitter.create(user_id: current_user.id, time_quit: Time.new.to_s)
		end			

		sign_out current_user
		redirect_to root_path
	end
	
	#Starting tetris
	def start_tetris
		#Check if Quitter record with current_user.id exists
		# If so, take that, update tetris_time to current time
		puts "starting tetris"
		Time.zone = "America/Los_Angeles"
		# if Quitter.exists?(user_id: current_user.id)
		# 	puts "User exists"
		# 	quitter = Quitter.find_by(user_id: current_user.id)
		# 	quitter.update(tetris_time: Time.new.to_s)
		# else
		Quitter.create(user_id: current_user.id, tetris_time: Time.new.to_s)
		# end		
		render :text => "Starting Tetris"
	end

	#Abort activity
	def abort_activity
		puts "aborting activity"
		Time.zone = "America/Los_Angeles"
		puts params[:id]
		# activityAbortedTime = Time.new.to_s + ""
		# Quitter.create(user_id: current_user.id, activityAbortTime: Time.new.to_s)

		render :text => "Aborting activity"
	end
end
