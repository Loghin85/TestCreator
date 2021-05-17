class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :logged_in_user, only: [:create, :new]
  skip_before_action :admin_user, only: [:create, :show, :new, :destroy, :edit, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
	if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
	end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
		
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if verify_recaptcha(model: @user) && @user.save  
			@user.send_activation_email
			# create example assessment with questions and submissions
			assessment = Assessment.new({"user_id"=>@user.id, "Name"=>"Example Assessment", "Description"=>"<p>This is an example assessment meant to help you create your own assessment and questions</p>", "Duration"=>"60", "BeginAt"=>"02/05/2021 10:45", "EndAt"=>"14/05/2025 10:45"})
			assessment.save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 1", "Text"=>"<p>Which of the following is not an animal?</p>", "Feedback"=>"<p>Unfortunately, Banana is not an animal.</p>", "Type"=>"MCQ", "Points"=>"10", "Options"=>"NEG0", "Answer"=>"〔Bear〕0%〔Banana〕100%〔Dolphin〕0%〔Monkey〕0%",}).save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 2", "Text"=>"<p>Which of the following integers are multiples of both 2 and 3?</p>", "Feedback"=>"<p>9 is not divisible by 2.&nbsp;</p>", "Type"=>"MA", "Points"=>"10", "Options"=>"NEG1P5PAR0", "Answer"=>"〔8〕100%〔9〕0%〔12〕100%〔18〕100%",}).save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 3", "Text"=>"<p>[blank] is the capital of France.</p>", "Feedback"=>"<p>The capital of France is Paris.</p>", "Type"=>"FTB", "Points"=>"5", "Options"=>"NEG0CON0CAS1MUL0", "Answer"=>"〔Paris〕100% ",}).save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 4", "Text"=>"<p>What is te sum of [X] and [Y]?</p>", "Feedback"=>"<p>To calculate the sum of two numbers just add them to eachother.</p>", "Type"=>"FRM", "Points"=>"10", "Options"=>"NEG0RAN1P0.5", "Answer"=>"〔[X]+[Y]〕100%〘X,0,5〙〘Y,0,10〙",}).save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 5", "Text"=>"<p>A full revolution of the earth around the sun takes exactly 365 days.</p>", "Feedback"=>"<p>The earthe completes a full revolution around the sum in 265 days and 6 hours. This is why we have bisect years.</p>", "Type"=>"TF", "Points"=>"20", "Options"=>"NEG1P5", "Answer"=>"〔False〕100%",}).save
			Question.new({"assessment_id"=>assessment.id, "Title"=>"Question 6", "Text"=>"<p>Stegosaurus is a species of [blank].</p>", "Feedback"=>"<p>Stegosaurus is a species of dinosaur.</p>", "Type"=>"REG", "Points"=>"10", "Options"=>"NEG0", "Answer"=>"〔^[Dd]inosaur$〕100%",}).save
			Submission.new({"assessment_id"=>assessment.id, "userId"=>"1234", "userEmail"=>"example@gmail.com", "Answers"=>"[\"Banana\", [\"9\", \"12\"], \"Berlin\", \"6\", \"False\", \"Ant\"]", "Scores"=>"[10, 0, 0, 10, 20, 0]", "Score"=>"0", "Duration"=>"2723", "SubmittedAt"=>"2021-05-13 16:12:25.131185"}).save
			Submission.new({"assessment_id"=>assessment.id, "userId"=>"1324", "userEmail"=>"example@gmail.com", "Answers"=>"[\"Monkey\", [\"9\", \"12\"], \"Paris\", \"4\", \"True\", \"Dog\"]", "Scores"=>"[0, 0, 5, 0, -5, 0]", "Score"=>"0", "Duration"=>"3423", "SubmittedAt"=>"2021-05-14 13:17:25.131185"}).save
			
			# create questions and assessment
			flash[:info] = "Please check your email to activate your account."
			redirect_to root_url
		else
			render 'new'
		end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
	if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
	else
		if verify_recaptcha(model: @user)
			problem = false
			update_params.each do |param|
				if !@user.update_attribute(param[0], param[1])
					problem = true
				end
			end
			respond_to do |format|
			  if !problem
				format.html { redirect_to @user
							flash[:info] = 'User was successfully updated.' }
				format.json { render :show, status: :ok, location: @user }
			  else
				format.html { render :edit }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			  end
			end
		else
		  flash[:info] = 'ReCAPTCHA not validated'
		  render 'edit'
		end
	end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
 	if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
	else
		@user.destroy
		respond_to do |format|
		  if admin?
			format.html { redirect_to users_url
						flash[:info] =  'User was successfully deleted.' }
		  else
			format.html { redirect_to root_url
						flash[:info] = 'User was successfully deleted.' }
		  end
		  format.json { head :no_content }
		end
	end
  end
  
  def allowed_params
	params.require(:user).permit(:email, :password, :password_confirmation)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
	
	def update_params
		params.require(:user).permit(:Fname, :Lname, :Email, :Privilege)
	end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:Fname, :Lname, :Email, :Privilege, :password, :password_confirmation)
    end
end
