class ActivitiesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_activity, only: [:show, :edit, :update, :destroy]  
  	#ensure only you have access to modify your posts
	before_action :owned_activity, only: [:edit, :update, :destroy] 

	def index
	  @activities = Activity.all
	  @users = User.all
	end

	def new
	  #@activity = Activity.new
	  @activity = current_user.activities.build
	end
	
	def create
	  @activity = current_user.activities.build(activity_params)

	  if @activity.save
		puts "CREATED ACTIVITY" 
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
    @activities = Activity.where(:user_id => params[:id])
  end

  # to display all of my completed activities
  def my_completed_activities
    @activities = Activity.where(["user_id = ? and is_completed = ?", params[:id], true])
  end


  #user details page
  def user_details
    @details = [User.find(current_user.id).score, User.find(current_user.id).level]
  end

  # Finish activity version that is a get request and takes in :act_id
  def finish_cur_activity
    puts "finish cur activity"
    @activity_id = params[:act_id]
    puts @activity_id
    puts current_user.id
    @activity = Activity.where("a_id = ? AND user_id = ?", @activity_id, current_user.id).first;
    puts @activity.points
    @user = User.find(current_user.id)
    puts @user.user_name
    @new_score = @user.score + @activity.points 
    puts @new_score
    @user.update(score: @new_score)
    puts Time.now
    @activity.update(activity_time_completed: Time.now);
    @activity.update(is_completed: true);

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id:  @activity_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil)
      puts "Activity exists with the user AND THE ACTIVITY IS FINISHED."
      quitter = Quitter.find_by! activity_id: @activity_id, user_id: current_user.id, activity_finish_time: nil, activityAbortTime: nil
      quitter.update(activity_finish_time: Time.new.to_s)
    else
      puts "This is called in the case that an activity is finished before it is started"
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activity_finish_time: Time.now.to_s)
    end 

    respond_to do |format|
      format.js { render js: "window.location.reload();" }  
    end
  end    

  #testing show message
  def finish_activity
    @activity_id = params[:activity_id]
    puts @activity_id
    @activity = Activity.where("a_id = ? AND user_id = ?", params[:activity_id], params[:user_id]).first;
    puts @activity.points
    @user = User.find(params[:user_id])
    puts @user.user_name
    @new_score = @user.score + @activity.points 
    puts @new_score
    @user.update(score: @new_score)
    puts Time.now
    @activity.update(activity_time_completed: Time.now);
    @activity.update(is_completed: true);

    # Update the Quitter class to record the time this activity finished
    # If activity has been started, hasn't been finished or aborted yet.
    if Quitter.exists?(activity_id:  @activity_id, user_id: params[:user_id], activity_finish_time: nil, activityAbortTime: nil)
      puts "Activity exists with the user AND THE ACTIVITY IS FINISHED."
      quitter = Quitter.find_by! activity_id: @activity_id, user_id: params[:user_id], activity_finish_time: nil, activityAbortTime: nil
      quitter.update(activity_finish_time: Time.new.to_s)
    else
      puts "This is called in the case that an activity is finished before it is started"
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activity_finish_time: Time.now.to_s)
    end 

    respond_to do |format|
      format.js { render js: "window.location.reload();" }  
    end
  end


  def get_activity_detail
    # @activity = Activity.where("a_id = ?", params[:id]);
    puts current_user.id
    # puts Activity.where("a_id = ? AND user_id = ?", params[:id], current_user.id).first
    @activity = Activity.where("a_id = ? AND user_id = ?", params[:id], current_user.id);
    puts "Getting activity detail"
    @act_duration = @activity.first.duration
    @act_code = @activity.first.code

    # if Quitter.exists?(activity_id: params[:id], user_id: current_user.id)
    #   puts "Activity exists with the user."
    #   quitter = Quitter.find_by(activity_id: params[:id])
    #   quitter.update(activity_start_time: Time.new.to_s)
    # else
    # Quitter.create(user_id: current_user.id, activity_id: params[:id], activity_start_time: Time.new.to_s)
    # end    

    render json: @activity
  end


  def start_activity
    Quitter.create(user_id: current_user.id, activity_id: params[:id], activity_start_time: Time.new.to_s)
    render :text => "Starting activity"
  end

  def delete_activity
    @activity_id = params[:id]
    @current_user_id = current_user.id
    Activity.where("a_id = ? AND user_id = ?", @activity_id, @current_user_id).destroy_all
    render :text => "delete activity"
  end

  def abort_activity
    Time.zone = "America/Los_Angeles"
    puts Time.zone.now.to_s
    @activity_id = params[:id]
    @activity = Activity.where("a_id = ?", params[:id]).first;
    @activity.update(abort_time: Time.now.to_s);

    @activityAbort = "Activity id: " + @activity_id + " Time: " + Time.now.to_s
    puts @activityAbort

  # If activity exists that has been started and hasnt been ended or aborted
    if Quitter.exists?(activity_id: params[:id], user_id: current_user.id, activityAbortTime: nil, activity_finish_time: nil)
      quitter = Quitter.find_by! activity_id: params[:id], user_id: current_user.id, activity_finish_time: nil
      puts "Activity exists with the user."
      quitter.update(activityAbortTime: Time.new.to_s)

    else
      puts "Create a new Quitter Record for activity abort time.  "
      Quitter.create(user_id: current_user.id, activity_id: @activity_id, activityAbortTime: Time.now.to_s)
    end 
    
    # puts @activity
    render :text => "abort activity"
  end

  def enable_admin
    puts "enabling admin for current user"
    puts params[:code].to_s	
    @adminCode = '9128'
    puts @adminCode.eql?(params[:code])
    if params[:code].eql?(@adminCode)
	if User.exists?(user_name: "Admin")
		puts "Admin Account exists, setting admin privleges"
		@adminUser = User.find_by(user_name: "Admin")
		@adminUser.update(is_admin: true)
	else
		puts "No admin account"
	end
	render :text => "admin enabled"
    else
    	render :text => "Wrong Code" 
    end
  end
  # def set_activity_id
  #   puts "activity_id"
  #   puts params[:activity_id]
  # end  


  def set_default_activities
    puts "setting default activites"
    puts params[:current_user]

    puts "Delete user's activities"

    if Activity.where(:user_id => params[:current_user]).exists?
      Activity.where(:user_id => params[:current_user]).destroy_all
      puts "destroying all previous activities"
    end

    puts "Also randomizing experimental condition"

    @control_condition = "control condition"
    @monetary_condition = "monetary condition"
    @points_condition = "points condition"

    experimental_condition = [@control_condition, @points_condition, @monetary_condition]

    @random_condition = experimental_condition.shuffle.sample

    puts "picking random condition"
    puts @random_condition
    User.find(current_user.id).update(:experimental_condition => @random_condition)
    puts "saving user's random condition"

    @admin_id = User.where(:user_name => "Admin")
    @activities = Activity.where(:user_id => @admin_id)
    puts @activities.count

    # Activity.destroy_all(:user_id => params[:current_user])
    @activities.each do |record|
      puts record
      Activity.new(content: record.content, user_id: params[:current_user], points: record.points, duration: record.duration, code: record.code, a_id: record.a_id).save
      puts "created new record"
    end    
    redirect_to root_path
  end


  def export_data
    # Function to render all data from activities and users for the experimenter 
    @quitters = Quitter.all

    render json: @quitters
    # render :text => "Rendering all data from database for export "
  end

  def export_user_data
    @users = User.all
    render json: @users
  end

  # Code generation for when users claim their payment
  # FORMAT: [activities completed] 9 [User Id] 9 [User quit] 9 [user Experimental condition]
  def generate_code
    @user_id = current_user.id
    @activities = Activity.where(:user_id => @user_id)
    @user_experimental_condition = current_user.experimental_condition
    @user_score = current_user.score
    @user_quit = current_user.is_active

    puts "Is user acitive"
    puts @user_quit
    puts @user_id
    puts @user_experimental_condition
    puts @user_score

    @score = "b"

    #Setting the activites Score
    @activities.each do |record|
      puts record
      if record.is_completed
        @score = @score + "1"
      else 
        @score = @score + "0"
      end
      puts @score
    end      
    @score = @score + "i"

    # User ID
    @score += @user_id.to_s
    @score = @score + "d"

    #user quit
    if @user_quit
      @score += "1"
    else
      @score += "0"
    end
    @score = @score + "q"

    #User experimental Condition
    if @user_experimental_condition == "Initial condition"
      @score += "1"
    else
      @score += "0"
    end
    @score += "e"
    puts @score
    
    render json: @score.to_json
  end

	private 

	def activity_params
	  params.require(:activity).permit(:image, :content, :points, :duration, :code, :a_id)
	end

  def set_activity
    @activity = Activity.find(params[:id])
    puts @activity[:duration]
    puts "The activities of this user"
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
