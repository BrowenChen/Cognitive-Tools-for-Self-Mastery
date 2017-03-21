class Admin::AnswersController < Admin::BaseController
  def index
    respond_to do |format|
      format.html { @answers = Answer.includes(:activity).page(params[:page]) }
      format.json { send_data Answer.all.to_json, type: 'application/json', disposition: :attachment }
    end
  end
end
