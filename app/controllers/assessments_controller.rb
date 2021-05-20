class AssessmentsController < ApplicationController
  before_action :set_assessment, only: %i[ show edit update destroy ]
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	skip_before_action :admin_user

  # GET /assessments or /assessments.json
	# prepares data for assessments page
  def index
		if !logged_in?
		naughty_user
		end
    @assessments = Assessment.where(user_id: current_user.id).order(:id)
  end

  # GET /assessments/1 or /assessments/1.json
	# prepares data for assessment details page
  def show
		@questions = Question.where(assessment_id: params[:id]).order(:id)
		@submissions = Submission.where(assessment_id: params[:id]).order(:id)
		@path = request.base_url+"/submissions/new?assessment_id=" +params[:id]
		# check if page should be accessed
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # GET /assessments/new
	# prepares data for new assessment page
  def new
		# check if page should be accessed
		if !logged_in?
		naughty_user
		end
    @assessment = Assessment.new
  end

  # GET /assessments/1/edit
	# prepares data for edit assessment page
  def edit
		# check if page should be accessed
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # POST /assessments or /assessments.json
	# creates and saves a new assessement
  def create
		# check for duplicate title
		assessments = Assessment.where(user_id: params[:assessment][:user_id])
		duplicateTitle = false
		for assessment in assessments
			if assessment.Name == params[:assessment][:Name]
				duplicateTitle = true
			end
		end
		#create new assessment
    @assessment = Assessment.new(assessment_params)
		respond_to do |format|
		  # get dates details
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
			# convert uset timezone to UTC
			if @assessment.BeginAt
				@assessment.BeginAt = @assessment.BeginAt + params[:offset].to_i.hours
			end
			if @assessment.EndAt
				@assessment.EndAt = @assessment.EndAt + params[:offset].to_i.hours
			end
			# if there are dates to begin with
			if params[:assessment][:BeginAt] != '' && params[:assessment][:EndAt] != ''
				beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
				endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
				# check if begins before it ends and if an assessment with the same title exists
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
	# updates and saves an assessment
  def update
		# check if user should be able to edit this assessment
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			# check for duplicate title
			assessments = Assessment.where(user_id: params[:assessment][:user_id])
			duplicateTitle = false
			for assessment in assessments
				if assessment.Name == params[:assessment][:Name]  && assessment.id != params[:id].to_i
					duplicateTitle = true
				end
			end
			respond_to do |format|
				# get dates details
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
				# if there are dates to begin with
				if params[:assessment][:BeginAt] != '' && params[:assessment][:EndAt] != ''
					beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
					endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
					# convert dates to UTC 
					paramEndAt = endAt + params[:offset].to_i.hours
					paramBeginAt = beginAt + params[:offset].to_i.hours
					params[:assessment][:BeginAt] = paramBeginAt.strftime('%d/%m/%Y %H:%M')
					params[:assessment][:EndAt] = paramEndAt.strftime('%d/%m/%Y %H:%M')
					# chec if the assessment should be updated or not
					if @assessment.update(assessment_params) && endAt > beginAt && !duplicateTitle
						format.html { redirect_to @assessment 
												flash[:info] = "Assessment was successfully updated." }
						format.json { render :show, status: :ok, location: @assessment }
					else
					params[:assessment][:BeginAt] = beginAt.strftime('%d/%m/%Y %H:%M')
					params[:assessment][:EndAt] = endAt.strftime('%d/%m/%Y %H:%M')
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
	# removes an assessment
  def destroy
		# check if user should be able to remove this assessment
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
		
		# callback to load the assessment creator
    def set_user
      @user = User.find(@assessment.user_id)
    end
		
    # callback to load the assessment
    def set_assessment
      @assessment = Assessment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assessment_params
      params.require(:assessment).permit(:user_id, :Name, :Description, :Duration, :BeginAt, :EndAt)
    end
end
