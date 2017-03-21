class Admin::AnswersController < Admin::BaseController
  def index
    respond_to do |format|
      format.html { @answers = Answer.includes(:activity).page(params[:page]) }
      format.json do
        json = Answer.includes(:activity, :user).all.as_json(
          only: :answer,
          include: {
            activity: { only: :activity_time_completed, methods: :question },
            user: { only: :user_name }
          }
        )

        send_data json, type: 'application/json', disposition: :attachment
      end
    end
  end
end
