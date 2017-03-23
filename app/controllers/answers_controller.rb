class AnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    @answer = current_user.answers.build(answer_params)
    raise if !current_user.is_admin? && @answer.activity.user_id != current_user.id # handle later

    @answer.save
  end

  private

  def answer_params
    params.require(:answer).permit(:activity_id, :answer)
  end
end
