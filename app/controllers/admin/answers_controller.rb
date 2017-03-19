class Admin::AnswersController < Admin::BaseController
  def index
    respond_to do |format|
      format.html { @answers = Answer.includes(:activity).page(params[:page]) }
      format.json do
        @answers = Answer.all
      end
    end
  end
end
