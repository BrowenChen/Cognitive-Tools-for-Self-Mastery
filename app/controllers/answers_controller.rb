class AnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    @answer = current_user.answers.build(answer_params)
    raise if !current_user.is_admin? && @answer.activity.user_id != current_user.id # handle later

    finish_current_activity if @answer.save
  end

  private

  def answer_params
    params.require(:answer).permit(:activity_id, :answer)
  end

  def finish_current_activity
    @activity = @answer.activity
    @user = current_user

    if current_user.experimental_condition != "control condition"
      @current_point_values = set_current_point_values(current_user)

      @new_score = current_user.score + @current_point_values[@activity.a_id-1]
      current_user.update(score: @new_score)

      if current_user.level < 2 && @new_score >= 150 && @new_score < 500
        current_user.update(level: 2)
      elsif current_user.level < 3 && @new_score >= 500 && @new_score < 1000
        current_user.update(level: 3)
      elsif current_user.level < 4 && @new_score >= 1000 && @new_score < 1500
        current_user.update(level: 4)
      elsif current_user.level < 5 && @new_score >= 1500
        current_user.update(level: 5)
      end
    end

    @activity.update(activity_time_completed: Time.now, is_completed: true)

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id: @activity.a_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil)
      quitter = Quitter.find_by! activity_id: @activity.a_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil
      quitter.update(activity_finish_time: Time.new.to_s)
    else
      Quitter.create(user_id: current_user.id, activity_id: @activity.a_id, activity_finish_time: Time.now.to_s)
    end

    unless current_user.activities.detect { |activity| !activity.is_completed }
      current_user.update(finished_all_activities: true)
    end

		# Updates all points for this user
    # set_current_point_values(current_user)
  end
end
