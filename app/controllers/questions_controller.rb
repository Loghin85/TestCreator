class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit update destroy ]
	skip_before_action :logged_in_user
	skip_before_action :admin_user

  # GET /questions or /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1 or /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
		@positions1 = []
		@positions2 = []

		pos = -1

		while (pos = @question.Answer.index("[", pos + 1))
		@positions1 << pos
		end
		
		pos = -1
		while (pos = @question.Answer.index("]", pos + 1))
		@positions2 << pos
		end
		p @positions1
  end

  # POST /questions or /questions.json
  def create
    options=""
		answer=""
		
		#form the options string
		if params[:Negative][:result]=="1"
			options=options+"NEG1P"+params[:negValue]
		else
			options=options+"NEG0"
		end
		if params[:question][:Type]=="MA"
			if params[:Partial][:result]=="1"
				options+="PAR1"
			else
				options+="PAR0"
			end
		end
		if params[:question][:Type]=="FTB"
			if params[:Contains][:result]=="1"
				options+="CON1"
			else
				options+="CON0"
			end
			if params[:CaseSensitive][:result]=="1"
				options+="CAS1"
			else
				options+="CAS0"
			end
			if params[:MultiSpaces][:result]=="1"
				options+="MUL1"
			else
				options+="MUL0"
			end
		end
		
		#form the answer string
		case params[:question][:Type]
		when "MCQ"
			case params[:MCQRadios]
			when "A"
				answer = "[" + params[:MCQRadio1] + "]100%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]0%"
			when "B"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]100%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]0%"
			when "C"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]100%" + "[" + params[:MCQRadio4] + "]0%"
			when "D"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]100%"
			end
		when "MA"
			correct = params[:MACheckboxes].clone
			if params[:Partial][:result]=="1"
					answer = answer + "[" +  params[:MACheckbox1]+ "]" + params[:MACheckbox1Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox2]+ "]" + params[:MACheckbox2Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox3]+ "]" + params[:MACheckbox3Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox4]+ "]" + params[:MACheckbox4Credit] + "%"
			else
				if correct.include?("A")
					answer = answer + "[" +  params[:MACheckbox1]+ "]100%"
				else
					answer = answer + "[" +  params[:MACheckbox1]+ "]0%"
				end
				if correct.include?("B")
					answer = answer + "[" +  params[:MACheckbox2]+ "]100%"
				else
					answer = answer + "[" +  params[:MACheckbox2]+ "]0%"
				end
				if correct.include?("C")
					answer = answer + "[" +  params[:MACheckbox3]+ "]100%"
				else
					answer = answer + "[" +  params[:MACheckbox3]+ "]0%"
				end
				if correct.include?("D")
					answer = answer + "[" +  params[:MACheckbox4]+ "]100%"
				else
					answer = answer + "[" +  params[:MACheckbox4]+ "]0%"
				end
			end
		when "FTB"
			answer = "[" + params[:FTBAnswer] + "]100%"
		when "TF"
			answer = "[" + params[:TFRadio] + "]100%"
		when "FRM"
			#do sth
		end
		
		@question = Question.new(question_params.merge(:Options => options, :Answer => answer))
			respond_to do |format|
				if @question.save
					format.html { redirect_to @question 
											flash[:info] = 'Question was successfully created.' }
					format.json { render :show, status: :created, location: @question }
				else
					format.html { render :new, status: :unprocessable_entity }
					format.json { render json: @question.errors, status: :unprocessable_entity }
				end
			end
  end

  # PATCH/PUT /questions/1 or /questions/1.json
  def update
		options=""
		answer=""
		
		#form the options string
		if params[:Negative][:result]=="1"
			options=options+"NEG1P"+params[:negValue]
		else
			options=options+"NEG0"
		end
		if params[:question][:Type]=="MA"
			if params[:Partial][:result]=="1"
				options+="PAR1"
			else
				options+="PAR0"
			end
		end
		if params[:question][:Type]=="FTB"
			if params[:Contains][:result]=="1"
				options+="CON1"
			else
				options+="CON0"
			end
			if params[:CaseSensitive][:result]=="1"
				options+="CAS1"
			else
				options+="CAS0"
			end
			if params[:MultiSpaces][:result]=="1"
				options+="MUL1"
			else
				options+="MUL0"
			end
		end
		
		#form the answer string
		case params[:question][:Type]
		when "MCQ"
			case params[:MCQRadios]
			when "A"
				answer = "[" + params[:MCQRadio1] + "]100%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]0%"
			when "B"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]100%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]0%"
			when "C"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]100%" + "[" + params[:MCQRadio4] + "]0%"
			when "D"
				answer = "[" + params[:MCQRadio1] + "]0%" + "[" + params[:MCQRadio2] + "]0%" + "[" + params[:MCQRadio3] + "]0%" + "[" + params[:MCQRadio4] + "]100%"
			end
		when "MA"
			correct = params[:MACheckboxes].clone
			if params[:Partial][:result]=="1"
					answer = answer + "[" +  params[:MACheckbox1]+ "]" + params[:MACheckbox1Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox2]+ "]" + params[:MACheckbox2Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox3]+ "]" + params[:MACheckbox3Credit] + "%"
					answer = answer + "[" +  params[:MACheckbox4]+ "]" + params[:MACheckbox4Credit] + "%"
			else
				if correct 
					if correct.include?("A")
						answer = answer + "[" +  params[:MACheckbox1]+ "]100%"
					else
						answer = answer + "[" +  params[:MACheckbox1]+ "]0%"
					end
					if correct.include?("B")
						answer = answer + "[" +  params[:MACheckbox2]+ "]100%"
					else
						answer = answer + "[" +  params[:MACheckbox2]+ "]0%"
					end
					if correct.include?("C")
						answer = answer + "[" +  params[:MACheckbox3]+ "]100%"
					else
						answer = answer + "[" +  params[:MACheckbox3]+ "]0%"
					end
					if correct.include?("D")
						answer = answer + "[" +  params[:MACheckbox4]+ "]100%"
					else
						answer = answer + "[" +  params[:MACheckbox4]+ "]0%"
					end
				end
			end
		when "FTB"
			answer = "[" + params[:FTBAnswer] + "]100%"
		when "TF"
			answer = "[" + params[:TFRadio] + "]100%"
		when "FRM"
			#do sth
		end
		
    respond_to do |format|
      if @question.update(question_params.merge(:Options => options, :Answer => answer))
        format.html { redirect_to @question 
										flash[:info] = 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1 or /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url 
									flash[:info] = 'Question was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:AssessmentId, :Title, :Text, :Feedback, :Type, :Points, :Answer, :Options)
    end
end
