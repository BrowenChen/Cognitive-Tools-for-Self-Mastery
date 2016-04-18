class RewardsController < ApplicationController

	def quit_experiment
		user = User.find_by(id: current_user.id)
		user.is_active = false
		user.save
		Time.zone = "America/Los_Angeles"
		Quitter.create(user_id: current_user.id, time_quit: Time.new.to_s)
		sign_out current_user
		redirect_to root_path
	end

end
