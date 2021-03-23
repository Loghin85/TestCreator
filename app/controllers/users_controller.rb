class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_action :logged_in_user, only: [:create, :new]
  skip_before_action :admin_user, only: [:create,:show, :new, :destroy, :edit, :update]

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
