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
		if params[:assessment_id]
			@submission.assessment_id = params[:assessment_id]
		elsif params[:submission]
			@submission.assessment_id = params[:submission][:assessment_id]
		end
		if @submission.assessment_id
			@assessment = Assessment.find(@submission.assessment_id)
			@questions = Question.where(assessment_id: @submission.assessment_id)
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
  end
	
	def feedback
		@submission = Submission.find(params[:submission])
		@assessment = Assessment.find(@submission.assessment_id)
		if @assessment
			user = User.find(@assessment.user_id)
			@creator = user.Fname + " " + user.Lname
		end
		@submission.send_feedback(params[:Feedback], @creator, @assessment)
		redirect_to '/submissions/'+params[:submission]
		flash[:info] = 'Feedback was successfully sent.'
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
			@questions = Question.where(assessment_id: @submission.assessment_id)
		end
  end

  # POST /submissions or /submissions.json
  def create
    params[:submission][:SubmittedAt]=DateTime.now
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
    if @submission.Scores == "Not submitted"
			p @submission.SubmittedAt.to_time
			date=DateTime.now
			# put if for expired case
			parms = {"Duration"=>((date.to_time-@submission.SubmittedAt.to_time)).to_i}
			scores = []
			answers = []
			@questions = Question.where(assessment_id: @submission.assessment_id)
			@assessment = Assessment.find(@submission.assessment_id)
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
			for question in @questions
				case question.Type
				when "MCQ"
					p "MCQ"
					answer = params[("MCQRadios-"+@questions.index(question).to_s).to_sym]
					qScore=0
					if answer != nil
						value = question.Answer[question.Answer.index(answer)+answer.length+1..question.Answer.index(answer)+question.Answer[question.Answer.index(answer)..].index("%")-1].to_i
						qScore=question.Points*value/100
					end
					if qScore == 0 && question.Options.include?("NEG1") && answer != nil
						qScore -= question.Options[5..].to_i
					end
					scores << qScore
					answers << answer
				when "MA"
					p "MA"
					answer = params[("MACheckboxes-"+@questions.index(question).to_s).to_sym]
					qScore=0
					wrong = false
					if answer != nil
						for check in answer
							if wrong == false
								value = question.Answer[question.Answer.index(check)+check.length+1..question.Answer.index(check)+question.Answer[question.Answer.index(check)..].index("%")-1].to_i
								if value == 0
									wrong = true
									qScore = 0
								end
								qScore+=question.Points*value/100
							end
						end
						qScore /= question.Answer.scan(/(?=100)/).count
					end
					if question.Options.include?("PAR0") && qScore != question.Points
						qScore = 0
					end
					if qScore == 0 && question.Options.include?("NEG1") && answer != nil
						qScore -= question.Options[5..question.Options.index("P")-1].to_i
					end
					answers << answer
					scores << qScore
				when "FTB"
					p "FTB"
					answer = params[("FTBAnswer-"+@questions.index(question).to_s).to_sym]
					answerCopy = answer
					targetAnswer = question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
					qScore=0
					if answer != nil
						if question.Options.include?("CAS0")
							targetAnswer = targetAnswer.upcase
							answerCopy = answerCopy.upcase
						end
						if question.Options.include?("MUL1")
							answerCopy = answer.squeeze().strip
						end
						if question.Options.include?("CON1")
							if answerCopy.include?(targetAnswer)
								qScore = question.Points
							end
						else
							if answerCopy == targetAnswer
								qScore = question.Points
							end
						end
					end
					if qScore == 0 && question.Options.include?("NEG1") && answerCopy != nil
						qScore -= question.Options[5..].to_i
					end
					scores << qScore
					answers << answer
				when "TF"
					p "TF"
					answer = params[("TFRadio-"+@questions.index(question).to_s).to_sym]
					qScore=0
					if answer != nil
						if question.Answer.include?(answer)
							qScore = question.Points
						end
					end
					if qScore == 0 && question.Options.include?("NEG1") && answer != nil
						qScore -= question.Options[5..].to_i
					end
					scores << qScore
					answers << answer
				when "REG"
					p "REG"
					answer = params[("REGAnswer-"+@questions.index(question).to_s).to_sym]
					regex = Regexp.new question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
					qScore=0
					if answer != nil
						if !(answer =~ regex).nil?
							qScore = question.Points
						end
					end
					if qScore == 0 && question.Options.include?("NEG1") && answer != nil
						qScore -= question.Options[5..].to_i
					end
					scores << qScore
					answers << answer
				when "FRM"
					p "FRM"
					values = eval(params[("FRMvalues-"+@questions.index(question).to_s).to_sym])
					formula = question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
					for val in values
						key, value = val
						formula = formula.gsub("[" + key.upcase + "]",value.to_s)
						formula = formula.gsub("[" + key.downcase + "]",value.to_s)
					end
					targetAnswer = eval(formula+".to_f").round(2)
					answer = params[("FRMAnswer-"+@questions.index(question).to_s).to_sym]
					qScore=0
					if answer != nil
						if question.Options.include?("RAN1")
							range = question.Options[question.Options.index("RAN1")+5..].to_f
							if answer.to_f >= targetAnswer-range && answer.to_f <= targetAnswer+range
								qScore = question.Points
							end
						else
							if answer.to_f == targetAnswer
								qScore = question.Points
							end
						end
					end
					if qScore == 0 && question.Options.include?("NEG1") && answer != nil
						qScore -= question.Options[5..].to_i
					end
					scores << qScore
					answers << answer
				end
				parms["Scores"] = scores
				parms["Answers"] = answers
			end
			respond_to do |format|
				if @submission.update(parms)
					@submission.send_submission_results(@assessment, @questions, @creator)
					format.html { redirect_to "/submissions/received" }
					format.json { redirect_to "/submissions/received" }
				else
					format.html { render :edit, status: :unprocessable_entity }
					format.json { render json: @submission.errors, status: :unprocessable_entity }
				end
			end
		else
			redirect_to "/submissions/duplicate", :notice => 'Failed to record the submission.'
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
