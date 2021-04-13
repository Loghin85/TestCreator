class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]
	before_action :logged_in_user, only: [:destroy, :show, :index]
	skip_before_action :admin_user
	
  # GET /submissions or /submissions.json
  def index
    @submissions = Submission.all
  end

  # GET /submissions/1 or /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
		if params[:assessment_id]
			@submission.assessment_id = params[:assessment_id]
		elsif params[:submission]
			@submission.assessment_id = params[:submission][:assessment_id]
		end
		if @submission.assessment_id
			@assessment = Assessment.find(@submission.assessment_id)
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
  end

  # GET /submissions/1/edit
  def edit
		if params[:assessment_id]
			@submission.assessment_id = params[:assessment_id]
		elsif params[:submission]
			@submission.assessment_id = params[:submission][:assessment_id]
		end
		if @submission.assessment_id
			@assessment = Assessment.find(@submission.assessment_id)
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
  end

  # POST /submissions or /submissions.json
  def create
    @submission = Submission.new(submission_params)
		if params[:submission][:assessment_id]
			assessment = Assessment.find(params[:submission][:assessment_id])
			@name = assessment.Name
			if assessment
				user = User.find(assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
    respond_to do |format|
      if @submission.save
        format.html { redirect_to edit_submission_path(@submission, :assessment_id => params[:submission][:assessment_id]) }
        format.json { render :show, status: :created, location: @submission }
      else
        
				format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: "Submission was successfully updated." }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: assessments_url)
									flash[:info] = "Submission was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:assessment_id, :userId, :userEmail, :Scores, :Answers, :SubmittedAt, :Score, :Duration)
    end
end
