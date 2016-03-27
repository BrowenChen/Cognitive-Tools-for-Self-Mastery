class CommentsController < ApplicationController
  before_action :set_activity

  def create
    @comment = @activity.comments.build(comment_params)
    @comment.user_id = current_user.id
   
    if @comment.save
      respond_to do |format|
        format.html { redirect_to root_path}
        format.js
      end
    else
      flash[:alert] = "Check the comment form"
      render root_path
    end
  end

  def destroy
    @comment = @activity.comments.find(params[:id])
    
    # If user_id == current user id

    if @comment.user_id == current_user.id
      @comment.destroy
      puts "TESTING DESTROY"
      respond_to do |format|
        format.html { redirect_to root_path}
        format.js
      end 
    end

  end

  private
 
  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end
end
