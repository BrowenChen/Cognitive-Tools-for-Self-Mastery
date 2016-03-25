class CommentsController < ApplicationController
  before_action :set_activity

  def create
    @comment = @activity.comments.build(comment_params)
    @comment.user_id = current_user.id
   
    if @comment.save
      flash[:success] = "Successful comment"
      redirect_to :back
    else
      flash[:alert] = "Check the comment form"
      render root_path
    end
  end

  def destroy
    @comment = @activity.comments.find(params[:id])
    @comment.destroy
    flash[:success] = "Comment Deleted"
    redirect_to root_path
  end

  private
 
  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end
end
