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
  end

  # POST /questions or /questions.json
  def create
    options=""
		p params[:question][:negValue]
		if params[:Negative][:result]=="1"
			options=options+"NEG1P"+params[:question][:negValue]
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
		@question = Question.new(question_params.merge(:Options => options))
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
    respond_to do |format|
      if @question.update(question_params)
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
									flash[:info] = 'Question was successfully destroyed.' }
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
      params.require(:question).permit(:AssessmentId, :Title, :Text, :Feedback, :Type, :Points)
    end
end
