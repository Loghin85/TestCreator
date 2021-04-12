class AssessmentsController < ApplicationController
  before_action :set_assessment, only: %i[ show edit update destroy ]
	skip_before_action :admin_user

  # GET /assessments or /assessments.json
  def index
    @assessments = Assessment.all
  end

  # GET /assessments/1 or /assessments/1.json
  def show
		@questions = Question.where(assessment_id: params[:id])
  end

  # GET /assessments/new
  def new
    @assessment = Assessment.new
  end

  # GET /assessments/1/edit
  def edit
  end

  # POST /assessments or /assessments.json
  def create
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
			if params[:assessment][:BeginAt] != '' && params[:assessment][:EndAt] != ''
				beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
				endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
				if @assessment.save && endAt > beginAt
					format.html { redirect_to @assessment
											flash[:info] = "Assessment was successfully created." }
					format.json { render :show, status: :created, location: @assessment }
				else
					format.html { render :new, status: :unprocessable_entity }
					format.json { render json: @assessment.errors, status: :unprocessable_entity }
					if endAt <= beginAt
						flash[:warning] = "Please choose an end date and time at least 1 minute later than the start date and time."
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
				beginAt = DateTime.new(yearB.to_i,monthB.to_i,dayB.to_i,hourB.to_i,minuteB.to_i)
				endAt = DateTime.new(yearE.to_i,monthE.to_i,dayE.to_i,hourE.to_i,minuteE.to_i)
				if @assessment.update(assessment_params) && endAt > beginAt
					format.html { redirect_to @assessment 
											flash[:info] = "Assessment was successfully updated." }
					format.json { render :show, status: :ok, location: @assessment }
				else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
					if endAt <= beginAt
						flash[:warning] = "Please choose an end date and time at least 1 minute later than the start date and time."
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
    respond_to do |format|
      if @assessment.update(assessment_params) && endAt > beginAt
        format.html { redirect_to @assessment 
										flash[:info] = "Assessment was successfully updated." }
        format.json { render :show, status: :ok, location: @assessment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
				if endAt <= beginAt
					flash[:warning] = "Please choose an end date and time at least 1 minute later than the start date and time."
				end
      end
    end
  end

  # DELETE /assessments/1 or /assessments/1.json
  def destroy
    @assessment.destroy
    respond_to do |format|
      format.html { redirect_to assessments_url
				flash[:info] ="Assessment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assessment
      @assessment = Assessment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assessment_params
      params.require(:assessment).permit(:user_id, :Name, :Description, :Duration, :BeginAt, :EndAt)
    end
end
