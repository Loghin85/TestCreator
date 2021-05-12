class AssessmentsController < ApplicationController
  before_action :set_assessment, only: %i[ show edit update destroy ]
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	skip_before_action :admin_user

  # GET /assessments or /assessments.json
  def index
		if !logged_in?
		naughty_user
		end
    @assessments = Assessment.where(user_id: current_user.id).order(:id)
  end

  # GET /assessments/1 or /assessments/1.json
  def show
		@questions = Question.where(assessment_id: params[:id]).order(:id)
		@submissions = Submission.where(assessment_id: params[:id]).order(:id)
		@path = request.base_url+"/submissions/new?assessment_id=" +params[:id]
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # GET /assessments/new
  def new
		if !logged_in?
		naughty_user
		end
    @assessment = Assessment.new
  end

  # GET /assessments/1/edit
  def edit
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # POST /assessments or /assessments.json
  def create
		assessments = Assessment.where(user_id: params[:assessment][:user_id])
		duplicateTitle = false
		for assessment in assessments
			if assessment.Name == params[:assessment][:Name]
				duplicateTitle = true
			end
		end
    @assessment = Assessment.new(assessment_params)
		respond_to do |format|
			yearB = params[:assessment][:BeginAt][6..9]
			monthB = params[:assessment][:BeginAt][3..4]
			dayB = params[:assessment][:BeginAt][0..1]
			hourB = params[:assessment][:BeginAt][11..12]
			minuteB = params[:assessment][:BeginAt][14..15]
			yearE = params[:assessment][:EndAt][6..9]
			monthE = params[:assessment][:EndAt][3..4]
			dayE = params[:assessment][:EndAt][0..1]
			hourE = params[:assessment][:EndAt][11..12]
			minuteE = params[:assessment][:EndAt][14..15]
			if @assessment.BeginAt
				@assessment.BeginAt = @assessment.BeginAt + params[:offset].to_i.hours
			end
			if @assessment.EndAt
				@assessment.EndAt = @assessment.EndAt + params[:offset].to_i.hours
			end
			if params[:assessment][:BeginAt] != '' && params[:assessment][:EndAt] != ''
				beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
				endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
				if endAt > beginAt && !duplicateTitle
					if @assessment.save
						format.html { redirect_to @assessment
												flash[:info] = "Assessment was successfully created." }
						format.json { render :show, status: :created, location: @assessment }
					else
						format.html { render :new, status: :unprocessable_entity }
						format.json { render json: @assessment.errors, status: :unprocessable_entity }
					end
				else
					format.html { render :new, status: :unprocessable_entity }
					format.json { render json: @assessment.errors, status: :unprocessable_entity }
					if endAt <= beginAt
						flash[:danger] = "Please choose an end date and time at least 1 minute later than the start date and time."
					end
					if duplicateTitle
						flash[:danger] = "An assessment with this title already exists."
					end
				end
			else
				if @assessment.save
					format.html { redirect_to @assessment
											flash[:info] = "Assessment was successfully created." }
					format.json { render :show, status: :created, location: @assessment }
				else
					format.html { render :new, status: :unprocessable_entity }
					format.json { render json: @assessment.errors, status: :unprocessable_entity }
				end
			end
		end
  end

  # PATCH/PUT /assessments/1 or /assessments/1.json
  def update
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			assessments = Assessment.where(user_id: params[:assessment][:user_id])
			duplicateTitle = false
			for assessment in assessments
				if assessment.Name == params[:assessment][:Name]  && assessment.id != params[:id].to_i
					duplicateTitle = true
				end
			end
			respond_to do |format|
				yearB = params[:assessment][:BeginAt][6..9]
				monthB = params[:assessment][:BeginAt][3..4]
				dayB = params[:assessment][:BeginAt][0..1]
				hourB = params[:assessment][:BeginAt][11..12]
				minuteB = params[:assessment][:BeginAt][14..15]
				yearE = params[:assessment][:EndAt][6..9]
				monthE = params[:assessment][:EndAt][3..4]
				dayE = params[:assessment][:EndAt][0..1]
				hourE = params[:assessment][:EndAt][11..12]
				minuteE = params[:assessment][:EndAt][14..15]
				if params[:assessment][:BeginAt] != '' && params[:assessment][:EndAt] != ''
					params[:assessment][:BeginAt][11..12] = "%02d" % (params[:assessment][:BeginAt][11..12].to_i+params[:offset].to_i).to_s
					params[:assessment][:EndAt][11..12] = "%02d" % (params[:assessment][:EndAt][11..12].to_i+params[:offset].to_i).to_s
					beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
					endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
					if @assessment.update(assessment_params) && endAt > beginAt && !duplicateTitle
						format.html { redirect_to @assessment 
												flash[:info] = "Assessment was successfully updated." }
						format.json { render :show, status: :ok, location: @assessment }
					else
					format.html { render :edit, status: :unprocessable_entity }
					format.json { render json: @assessment.errors, status: :unprocessable_entity }
						if endAt <= beginAt
							flash[:danger] = "Please choose an end date and time at least 1 minute later than the start date and time."
						end
						if duplicateTitle
							flash[:danger] = "An assessment with this title already exists."
						end
					end
				else
					if @assessment.update(assessment_params)
						format.html { redirect_to @assessment 
												flash[:info] = "Assessment was successfully updated." }
						format.json { render :show, status: :ok, location: @assessment }
					else
					format.html { render :edit, status: :unprocessable_entity }
					format.json { render json: @assessment.errors, status: :unprocessable_entity }
					end
				end
			end
		end
  end

  # DELETE /assessments/1 or /assessments/1.json
  def destroy
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			@assessment.destroy
			respond_to do |format|
				format.html { redirect_to assessments_url
					flash[:info] ="Assessment was successfully destroyed." }
				format.json { head :no_content }
			end
		end
  end

  private
		
    def set_user
      @user = User.find(@assessment.user_id)
    end
		
    # Use callbacks to share common setup or constraints between actions.
    def set_assessment
      @assessment = Assessment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assessment_params
      params.require(:assessment).permit(:user_id, :Name, :Description, :Duration, :BeginAt, :EndAt)
    end
end
