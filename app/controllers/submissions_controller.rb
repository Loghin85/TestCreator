class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]
	before_action :logged_in_user, only: [:destroy, :show, :index, :feedback]
	before_action :set_user, only: [:show, :destroy, :index]
	skip_before_action :admin_user

  # GET /submissions/1 or /submissions/1.json
  def show
		# check is user should see this submission
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			# check if assessment id is provided
			if params[:assessment_id]
				@submission.assessment_id = params[:assessment_id]
			# or submission is provided
			elsif params[:submission]
				@submission.assessment_id = params[:submission][:assessment_id]
			end
			# if an id has been aquiered
			if @submission.assessment_id
				@assessment = Assessment.find(@submission.assessment_id)
				@questions = Question.where(assessment_id: @submission.assessment_id).order(:id)
				# if the assessment exists
				if @assessment
					user = User.find(@assessment.user_id)
					@creator = user.Fname + " " + user.Lname
				end
			end
		end
  end
	
	# method called when an educator sends further feedback
	def feedback
		@submission = Submission.find(params[:submissionFeedback][:id])
		@assessment = Assessment.find(@submission.assessment_id)
		# if the assessment exists
		if @assessment
			user = User.find(@assessment.user_id)
			@creator = user.Fname + " " + user.Lname
		end
		@submission.send_feedback(params[:submissionFeedback][:Feedback], @creator, @assessment)
		redirect_to '/submissions/'+params[:submissionFeedback][:id]
		flash[:info] = 'Feedback was successfully sent.'
	end

  # GET /submissions/new
	# load data for the identification page
  def new
    @submission = Submission.new
		# check if assessment id is provided
		if params[:assessment_id]
			@submission.assessment_id = params[:assessment_id]
		# or submission is provided
		elsif params[:submission]
			@submission.assessment_id = params[:submission][:assessment_id]
		end
		# if an id has been aquiered
		if @submission.assessment_id
			@assessment = Assessment.find(@submission.assessment_id)
			# if the assessment exists
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
  end

  # GET /submissions/1/edit
	# load data for the attempt page
  def edit
		# check if assessment id is provided
		if params[:assessment_id]
			@submission.assessment_id = params[:assessment_id]
		# or submission is provided
		elsif params[:submission]
			@submission.assessment_id = params[:submission][:assessment_id]
		end
		# if an id has been aquiered
		if @submission.assessment_id
			@assessment = Assessment.find(@submission.assessment_id)
			# if the assessment exists
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
			@questions = Question.where(assessment_id: @submission.assessment_id).order(:id)
		end
  end

  # POST /submissions or /submissions.json
	# method called when a student identifies
  def create
    # start time
		params[:submission][:SubmittedAt]=DateTime.now
		@submission = Submission.new(submission_params)
		# if assessment id was provided 
		if params[:submission][:assessment_id]
			@assessment = Assessment.find(params[:submission][:assessment_id])
			@name = @assessment.Name
			# if the assessment exists
			if @assessment
				user = User.find(@assessment.user_id)
				@creator = user.Fname + " " + user.Lname
			end
		end
    respond_to do |format|
      if @submission.save
        format.html { redirect_to edit_submission_path(@submission, :assessment_id => params[:submission][:assessment_id]) }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html {render :new, :locals => { :assessment => @assessment }, status: :unprocessable_entity}
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  # method called on assessment submission
	def update
    if @submission.Scores == "Not submitted"
			# end time
			date=DateTime.now
			@assessment = Assessment.find(@submission.assessment_id)
			# if within time limit
			if date.to_time < @submission.SubmittedAt.to_time + @assessment.Duration.minutes + 5.seconds
				parms = {"Duration"=>((date.to_time-@submission.SubmittedAt.to_time)).to_i}
				scores = []
				answers = []
				@questions = Question.where(assessment_id: @submission.assessment_id).order(:id)
				@assessment = Assessment.find(@submission.assessment_id)
				# if assessment exists
				if @assessment
					user = User.find(@assessment.user_id)
					@creator = user.Fname + " " + user.Lname
				end
				# for every question of the assessment
				for question in @questions
					case question.Type
					# if multiple choice
					when "MCQ"
						answer = params[("MCQRadios-"+@questions.index(question).to_s).to_sym]
						qScore=0
						# if there was an answer
						if answer != nil
							# get the percentage value of that answer
							value = question.Answer[question.Answer.index(answer)+answer.length+1..question.Answer.index(answer)+question.Answer[question.Answer.index(answer)..].index("%")-1].to_i
							# set the quesiton score
							qScore=question.Points*value/100
						end
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answer != nil
							qScore -= question.Options[5..].to_i
						end
						# add score and answer to their respective array
						scores << qScore
						answers << answer
					# if multiple answer
					when "MA"
						answer = params[("MACheckboxes-"+@questions.index(question).to_s).to_sym]
						qScore=0
						wrong = false
						# if there was an answer
						if answer != nil
							# for each selected answer
							for check in answer
								# check if wrong answer was chosen
								if wrong == false
									value = question.Answer[question.Answer.index(check)+check.length+1..question.Answer.index(check)+question.Answer[question.Answer.index(check)..].index("%")-1].to_i
									# if answer was wrong
									if value == 0
										wrong = true
										qScore = 0
									end
									# update question score
									qScore+=question.Points*value/100
								end
							end
							# fix the score for questions with no partial marking
							if question.Answer.scan(/(?=100)/).count != 0
								qScore /= question.Answer.scan(/(?=100)/).count
							end
						end
						# if partial marking was not active and the answer is not complete
						if question.Options.include?("PAR0") && qScore != question.Points
							qScore = 0
						end
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answer != nil
							qScore -= question.Options[5..question.Options.index("P")-1].to_i
						end
						# add score and answer to their respective array
						answers << answer
						scores << qScore
					# if fill the blank
					when "FTB"
						answer = params[("FTBAnswer-"+@questions.index(question).to_s).to_sym]
						answerCopy = answer
						targetAnswer = question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
						qScore=0
						# if there was an answer
						if answer != nil
							#if the answer is not case sensitive act accordingly
							if question.Options.include?("CAS0")
								targetAnswer = targetAnswer.upcase
								answerCopy = answerCopy.upcase
							end
							#if multiple spaces are allowed act accordingly
							if question.Options.include?("MUL1")
								answerCopy = answer.squeeze().strip
							end
							#if answers that contain the correct answer are allowed act accordingly
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
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answerCopy != nil
							qScore -= question.Options[5..].to_i
						end
						# add score and answer to their respective array
						scores << qScore
						answers << answer
					# if true false
					when "TF"
						answer = params[("TFRadio-"+@questions.index(question).to_s).to_sym]
						qScore=0
						# if there was an answer
						if answer != nil
							# if the answer was correct
							if question.Answer.include?(answer)
								qScore = question.Points
							end
						end
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answer != nil
							qScore -= question.Options[5..].to_i
						end
						# add score and answer to their respective array
						scores << qScore
						answers << answer
					# if regular expression
					when "REG"
						answer = params[("REGAnswer-"+@questions.index(question).to_s).to_sym]
						regex = Regexp.new question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
						qScore=0
						# if there was an answer
						if answer != nil
							# if the answer was correct
							if !(answer =~ regex).nil?
								qScore = question.Points
							end
						end
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answer != nil
							qScore -= question.Options[5..].to_i
						end
						# add score and answer to their respective array
						scores << qScore
						answers << answer
					# if formula
					when "FRM"
						values = eval(params[("FRMvalues-"+@questions.index(question).to_s).to_sym])
						formula = question.Answer[question.Answer.index("〔")+1..question.Answer.index("〕")-1]
						# calculate the correct answer with the student variable values
						for val in values
							key, value = val
							formula = formula.gsub("[" + key.upcase + "]",value.to_s)
							formula = formula.gsub("[" + key.downcase + "]",value.to_s)
						end
						# round it
						targetAnswer = eval(formula+".to_f").round(2)
						answer = params[("FRMAnswer-"+@questions.index(question).to_s).to_sym]
						qScore=0
						# if there was an answer
						if answer != nil
							# if answer error was allowed act accordingly
							if question.Options.include?("RAN1")
								range = question.Options[question.Options.index("RAN1")+5..].to_f
								# if within range
								if answer.to_f >= targetAnswer-range && answer.to_f <= targetAnswer+range
									qScore = question.Points
								end
							else
								# if answer mathces
								if answer.to_f == targetAnswer
									qScore = question.Points
								end
							end
						end
						# if negatime marking was active apply it
						if qScore == 0 && question.Options.include?("NEG1") && answer != nil
							qScore -= question.Options[5..].to_i
						end
						# add score and answer to their respective array
						scores << qScore
						answers << answer
					end
					# set the scores and answers parameters
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
				redirect_to root_url
			end
		else
			redirect_to "/submissions/duplicate", :error => 'Failed to record the submission.'
		end
  end

  # DELETE /submissions/1 or /submissions/1.json
	# called when a submission is destroyed
  def destroy
		# check if the user shouldbe able to destroy the question
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			@submission.destroy
			respond_to do |format|
				format.html { redirect_back(fallback_location: assessments_url)
										flash[:info] = "Submission was successfully destroyed." }
				format.json { head :no_content }
			end
		end
  end

  private
    # callback to set the assessment creator
    def set_user
      assessment = Assessment.find(@submission.assessment_id)
			@user = User.find(assessment.user_id)
    end
		
    # callback to set the submission
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:assessment_id, :userId, :userEmail, :Scores, :Answers, :SubmittedAt, :Score, :Duration)
    end
end
