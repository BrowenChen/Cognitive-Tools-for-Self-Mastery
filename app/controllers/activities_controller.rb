class ActivitiesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_activity, only: [:show, :edit, :update, :destroy]  
  #ensure only you have access to modify your posts
  before_action :owned_activity, only: [:edit, :update, :destroy] 

	def index
	  @activities = Activity.all
	end

	def new
	  #@activity = Activity.new
	  @activity = current_user.activities.build
	end
	
	def create
	  @activity = current_user.activities.build(activity_params)

	  if @activity.save
		flash[:success] = "Your activity has been created!"
		redirect_to activities_path
	  else
		flash[:alert]  = "Your new activity couldn't be created!"
		render :new
	  end
	end

	def show
	  @activity = Activity.find(params[:id])
	end

	def edit  
	end

	def update  
  	  if @activity.update(activity_params)
      	flash[:success] = "Activity updated."
      	redirect_to activities_path  
      else
        flash.now[:alert] = "Update failed.  Please check the form."
        render :edit
      end      		  	
  	  # redirect_to(activity_path(@activity))
	end  

	def destroy
	  @activity = Activity.find(params[:id])
	  @activity.destroy
	  redirect_to activities_path	  
	end

  # to display all of my activities
  def my_activities
    @activities = Activity.all
  end

	private 

	def activity_params
	  params.require(:activity).permit(:image, :content)
	end

  def set_activity
    @activity = Activity.find(params[:id])
  end	

  def owned_activity 
    unless current_user == @activity.user
      flash[:alert] = "That post doesn't belong to you!"
      redirect_to root_path  
    end    
  end

  # before_action :set_post, only: [:show, :edit, :update, :destroy]

  # # GET /posts
  # # GET /posts.json
  # def index
  #   @posts = Post.all
  # end

  # # GET /posts/1
  # # GET /posts/1.json
  # def show
  # end

  # # GET /posts/new
  # def new
  #   @post = Post.new
  # end

  # # GET /posts/1/edit
  # def edit
  # end

  # # POST /posts
  # # POST /posts.json
  # def create
  #   @post = Post.new(post_params)

  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to @post, notice: 'Post was successfully created.' }
  #       format.json { render :show, status: :created, location: @post }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /posts/1
  # # PATCH/PUT /posts/1.json
  # def update
  #   respond_to do |format|
  #     if @post.update(post_params)
  #       format.html { redirect_to @post, notice: 'Post was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @post }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /posts/1
  # # DELETE /posts/1.json
  # def destroy
  #   @post.destroy
  #   respond_to do |format|
  #     format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_post
  #     @post = Post.find(params[:id])
  #   end

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def post_params
  #     params.fetch(:post, {})
  #   end	
end
