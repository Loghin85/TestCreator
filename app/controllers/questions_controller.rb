class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit update destroy ]
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	skip_before_action :admin_user

  # GET /questions or /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1 or /questions/1.json
  def show
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # GET /questions/new
  def new
		assessment = Assessment.find(params[:assessment_id])
		user = User.find(assessment.user_id)
		if !logged_in? || (!admin? && !(current_user == user))
		naughty_user
		else
			@question = Question.new
			if params[:assessment_id]
				@question.assessment_id = params[:assessment_id]
			elsif params[:question]
				@question.assessment_id = params[:question][:assessment_id]
			end
		end
  end

  # GET /questions/1/edit
  def edit
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			@positions1 = []
			@positions2 = []
			@values = []
				if params[:assessment_id]
					@question.assessment_id = params[:assessment_id]
				elsif params[:question]
					@question.assessment_id = params[:question][:assessment_id]
				end 

			indx= -1
			while (indx= @question.Answer.index("〔", indx+ 1))
				@positions1 << indx
			end

			indx= -1
			while (indx= @question.Answer.index("〕", indx+ 1))
				@positions2 << indx
			end
				
			while (@positions1.length < 4)
				@positions1 << -1
				@positions2 << -1
			end
				
			if @question.Type == "FRM"
				text= @question.Answer[@question.Answer.index("〘")..-1]
				positionsComma = []
				positionsEB = []
				indx= -1
				while (indx= text.index(",", indx+ 1))
					positionsComma << indx
				end
				indx= -1
				while (indx= text.index("〙", indx+ 1))
					positionsEB << indx
				end
				for i in 0..positionsComma.length/2-1
					var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
					@values << var
				end
			end
		end
  end

  # POST /questions or /questions.json
  def create
		assessment = Assessment.find(params[:question][:assessment_id])
		user = User.find(assessment.user_id)
		if !logged_in? || (!admin? && !(current_user == user))
		naughty_user
		else
			options=""
			answer=""
			questions = Question.where(assessment_id: params[:question][:assessment_id])
			duplicateTitle = false
			
			for question in questions
				if question.Title == params[:question][:Title]
					duplicateTitle = true
				end
			end
				
			#form the options string
			if params[:Negative][:result]=="1"
				options=options+"NEG1P"+params[:negValue].to_i.abs().to_s
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
			if params[:question][:Type]=="FRM"
				if params[:Range][:result]=="1"
					options+="RAN1P"+params[:rangeValue]
				else
					options+="RAN0"
				end
			end
				
			#form the answer string
			case params[:question][:Type]
			when "MCQ"
				case params[:MCQRadios]
				when "A"
					answer = "〔" + params[:MCQRadio1] + "〕100%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "B"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕100%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "C"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕100%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "D"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕100%"
				end
				if answer.length == 18
					answer=nil
				end
			when "MA"
				correct = params[:MACheckboxes].clone
				if params[:Partial][:result]=="1"
						answer = answer + "〔" +  params[:MACheckbox1]+ "〕" + params[:MACheckbox1Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox2]+ "〕" + params[:MACheckbox2Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox3]+ "〕" + params[:MACheckbox3Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox4]+ "〕" + params[:MACheckbox4Credit] + "%"
				else
					if !correct.nil?
						if correct.include?("A")
							answer = answer + "〔" +  params[:MACheckbox1]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox1]+ "〕0%"
						end
						if correct.include?("B")
							answer = answer + "〔" +  params[:MACheckbox2]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox2]+ "〕0%"
						end
						if correct.include?("C")
							answer = answer + "〔" +  params[:MACheckbox3]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox3]+ "〕0%"
						end
						if correct.include?("D")
							answer = answer + "〔" +  params[:MACheckbox4]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox4]+ "〕0%"
						end
						if answer.length == 18
							answer=nil
						end
					else
						answer=nil
					end
				end
			when "FTB"
				answer = "〔" + params[:FTBAnswer] + "〕100%"
				if answer.length == 6
					answer=nil
				end
			when "TF"
				answer = "〔" + params[:TFRadio] + "〕100%"
			when "REG"
				answer = "〔" + params[:REGAnswer] + "〕100%"
				if answer.length == 6
					answer=nil
				end
			when "FRM"
				formula = params[:FRMAnswer]
				answer = "〔" + params[:FRMAnswer] + "〕100%"
				vars={}
				res = formula.scan(/([\[][A-Z]+[\]])/)
				for var in res
					tag=var[0][1..var[0].length-2].upcase
					vars[tag]=[params[(tag+"Min").intern].to_i,params[(tag+"Max").intern].to_i]
					answer = answer + "〘" + tag + "," + vars[tag][0].to_s + "," + vars[tag][1].to_s + "〙"
				end
				relationsRegex= /\A((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+)((,| ,|, | , )((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+))*\Z/
				formulaRegex= /((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)/
				relations = params[:FRMRelations]
				if relations == nil
				 relations = ""
				end
				test = formula.scan(formulaRegex) #test formula for valid format
				test1 = relations.match(relationsRegex) #test relations for valid format
				test2 = relations.scan(/([\[][A-Z]+[\]])/) #test for foreign variables
				foreignVars = false
				for var in test2
					tag=var[0][1..var[0].length-2].upcase
					if !vars.key?(tag)
						foreignVars = true
					end
				end
				p (test1 == nil && relations.length != 0)
				p !foreignVars
				p test.length == 0
				if (test1 == nil && relations.length != 0) || foreignVars || test.length == 0
					answer=""
					p 'here'
				elsif relations.length != 0
					answer = answer + "〚" + relations + "〛"
				end
				m = Cbc::Model.new
				rels=[]
				for rel in relations.split(',')
					rel = rel.strip
					rel.gsub! '+', ' + '
					rel.gsub! '-', ' - '
					rel.gsub! '*', ' * '
					rel.gsub! '/', ' / '
					rel.gsub! '<=', ' <= '
					rel.gsub! '>=', ' >= '
					rel.gsub! '=', ' = '
					rel.gsub! '< =', '<='
					rel.gsub! '> =', '>='
					rels << rel
				end
				#left here
				if answer.length != 0
					varsILP={}
					maximize=0
					for var in vars
						varsILP[var[0]]=m.int_var(var[1][0]..var[1][1])
						sign=rand(1..2)
						if sign == 1
							maximize = maximize + rand(1..20) * varsILP[var[0]]
						elsif sign == 2
							maximize = maximize - rand(1..20) * varsILP[var[0]]
						end
					end
					m.maximize(maximize)
					for rel in rels
						eq=0
						blocks=rel.split()
						if blocks[0][0]=="["
							if blocks[2][0]=="["
								eq= varsILP[blocks[0][1].upcase].send(blocks[1],varsILP[blocks[2][1].upcase])
							else
								eq= varsILP[blocks[0][1].upcase].send(blocks[1],blocks[2].to_i)
							end
						else
							if blocks[2][0]=="["
								eq= blocks[0].to_i.send(blocks[1],varsILP[blocks[2][1].upcase])
							else
								eq= blocks[0].to_i.send(blocks[1],blocks[2].to_i)
							end
						end
						for i in (3..blocks.length-2).step(2)
							if blocks[i+1][0]=="["
								eq = eq.send(blocks[i],varsILP[blocks[i+1][1].upcase])
							else
								eq = eq.send(blocks[i],blocks[i+1].to_i)
							end
						end
						m.enforce(eq)
					end
					
					p = m.to_problem
					p.solve

					if p.proven_infeasible?
						infeasible = true
					else
						infeasible = false
					end
				end
			end
			
			@question = Question.new(question_params.merge(:Options => options, :Answer => answer))
			respond_to do |format|
			if duplicateTitle
				@question.errors.add(:Title, :duplicate)
			end
			if infeasible
				@question.errors.add(:Answer, :infeasible)
			end
				if @question.errors.any?
					if answer!=nil
						@positions1 = []
						@positions2 = []
						@values = []

						indx= -1
						while (indx= @question.Answer.index("〔", indx+ 1))
						@positions1 << indx
						end

						indx= -1
						while (indx= @question.Answer.index("〕", indx+ 1))
							@positions2 << indx
						end
						
						while (@positions1.length < 4)
							@positions1 << -1
							@positions2 << -1
						end
						if @question.Type == "FRM"
							text= @question.Answer[@question.Answer.index("〘")..-1]
							positionsComma = []
							positionsEB = []
							indx= -1
							while (indx= text.index(",", indx+ 1))
								positionsComma << indx
							end
							indx= -1
							while (indx= text.index("〙", indx+ 1))
								positionsEB << indx
							end
							for i in 0..positionsComma.length/2-1
								var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
								@values << var
							end
						end
					format.html { render :new, status: :unprocessable_entity }
					format.json { render json: @question.errors, status: :unprocessable_entity }
					end
				else
					if @question.save
						format.html { redirect_to @question 
												flash[:info] = 'Question was successfully created.' }
						format.json { render :show, status: :created, location: @question }
					else
						if answer!=nil
							@positions1 = []
							@positions2 = []
							@values = []

							indx= -1
							while (indx= @question.Answer.index("〔", indx+ 1))
							@positions1 << indx
							end

							indx= -1
							while (indx= @question.Answer.index("〕", indx+ 1))
								@positions2 << indx
							end
							
							while (@positions1.length < 4)
								@positions1 << -1
								@positions2 << -1
							end
							if @question.Type == "FRM"
								text= @question.Answer[@question.Answer.index("〘")..-1]
								positionsComma = []
								positionsEB = []
								indx= -1
								while (indx= text.index(",", indx+ 1))
									positionsComma << indx
								end
								indx= -1
								while (indx= text.index("〙", indx+ 1))
									positionsEB << indx
								end
								for i in 0..positionsComma.length/2-1
									var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
									@values << var
								end
							end
						end
						format.html { render :new, status: :unprocessable_entity }
						format.json { render json: @question.errors, status: :unprocessable_entity }
					end
				end
			end
		end
  end

  # PATCH/PUT /questions/1 or /questions/1.json
  def update
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			options=""
			answer=""
			questions = Question.where(assessment_id: params[:question][:assessment_id])
			duplicateTitle = false
			
			for question in questions
				if question.Title == params[:question][:Title] && question.id != params[:id].to_i
					duplicateTitle = true
				end
			end
			
			#form the options string
			if params[:Negative][:result]=="1"
				p params[:negValue].to_i.abs().to_s
				options=options+"NEG1P"+params[:negValue].to_i.abs().to_s
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
			if params[:question][:Type]=="FRM"
				if params[:Range][:result]=="1"
					options+="RAN1P"+params[:rangeValue]
				else
					options+="RAN0"
				end
			end
			
			#form the answer string
			case params[:question][:Type]
			when "MCQ"
				case params[:MCQRadios]
				when "A"
					answer = "〔" + params[:MCQRadio1] + "〕100%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "B"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕100%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "C"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕100%" + "〔" + params[:MCQRadio4] + "〕0%"
				when "D"
					answer = "〔" + params[:MCQRadio1] + "〕0%" + "〔" + params[:MCQRadio2] + "〕0%" + "〔" + params[:MCQRadio3] + "〕0%" + "〔" + params[:MCQRadio4] + "〕100%"
				end
				if answer.length == 18
					answer=nil
				end
			when "MA"
				correct = params[:MACheckboxes].clone
				if params[:Partial][:result]=="1"
						answer = answer + "〔" +  params[:MACheckbox1]+ "〕" + params[:MACheckbox1Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox2]+ "〕" + params[:MACheckbox2Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox3]+ "〕" + params[:MACheckbox3Credit] + "%"
						answer = answer + "〔" +  params[:MACheckbox4]+ "〕" + params[:MACheckbox4Credit] + "%"
				else
					if !correct.nil?
						if correct.include?("A")
							answer = answer + "〔" +  params[:MACheckbox1]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox1]+ "〕0%"
						end
						if correct.include?("B")
							answer = answer + "〔" +  params[:MACheckbox2]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox2]+ "〕0%"
						end
						if correct.include?("C")
							answer = answer + "〔" +  params[:MACheckbox3]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox3]+ "〕0%"
						end
						if correct.include?("D")
							answer = answer + "〔" +  params[:MACheckbox4]+ "〕100%"
						else
							answer = answer + "〔" +  params[:MACheckbox4]+ "〕0%"
						end
						if answer.length == 18
							answer=nil
						end
					else
						answer=nil
					end
				end
			when "FTB"
				answer = "〔" + params[:FTBAnswer] + "〕100%"
				if answer.length == 6
					answer=nil
				end
			when "TF"
				answer = "〔" + params[:TFRadio] + "〕100%"
			when "REG"
				answer = "〔" + params[:REGAnswer] + "〕100%"
				if answer.length == 6
					answer=nil
				end
			when "FRM"
				formula = params[:FRMAnswer]
				answer = "〔" + params[:FRMAnswer] + "〕100%"
				vars={}
				res = formula.scan(/([\[][A-Z]+[\]])/)
				for var in res
					tag=var[0][1..var[0].length-2].upcase
					vars[tag]=[params[(tag+"Min").intern].to_i,params[(tag+"Max").intern].to_i]
					answer = answer + "〘" + tag + "," + vars[tag][0].to_s + "," + vars[tag][1].to_s + "〙"
				end
				relationsRegex= /\A((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+)((,| ,|, | , )((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+))*\Z/
				formulaRegex= /((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)/
				if params[:FRMRelations]
					relations = params[:FRMRelations]
				else	
					relations = ""
				end
				test = formula.scan(formulaRegex) #test formula for valid format
				test1 = relations.match(relationsRegex) #test relations for valid format
				test2 = relations.scan(/([\[][A-Z]+[\]])/) #test for foreign variables
				foreignVars = false
				for var in test2
					tag=var[0][1..var[0].length-2].upcase
					if !vars.key?(tag)
						foreignVars = true
					end
				end
				if (test1 == nil && relations.length != 0) || foreignVars || test.length == 0
					answer=""
				elsif relations.length != 0
					answer = answer + "〚" + relations + "〛"
				end
				m = Cbc::Model.new
				p relations
				rels=[]
				for rel in relations.split(',')
					rel = rel.strip
					rel.gsub! '+', ' + '
					rel.gsub! '-', ' - '
					rel.gsub! '*', ' * '
					rel.gsub! '/', ' / '
					rel.gsub! '<=', ' <= '
					rel.gsub! '>=', ' >= '
					rel.gsub! '=', ' = '
					rel.gsub! '< =', '<='
					rel.gsub! '> =', '>='
					rels << rel
				end
				#left here
				if answer.length != 0
					varsILP={}
					maximize=0
					for var in vars
						varsILP[var[0]]=m.int_var(var[1][0]..var[1][1])
						sign=rand(1..2)
						if sign == 1
							maximize = maximize + rand(1..20) * varsILP[var[0]]
						elsif sign == 2
							maximize = maximize - rand(1..20) * varsILP[var[0]]
						end
					end
					m.maximize(maximize)
					for rel in rels
						eq=0
						blocks=rel.split()
						if blocks[0][0]=="["
							if blocks[2][0]=="["
								eq= varsILP[blocks[0][1].upcase].send(blocks[1],varsILP[blocks[2][1].upcase])
							else
								eq= varsILP[blocks[0][1].upcase].send(blocks[1],blocks[2].to_i)
							end
						else
							if blocks[2][0]=="["
								eq= blocks[0].to_i.send(blocks[1],varsILP[blocks[2][1].upcase])
							else
								eq= blocks[0].to_i.send(blocks[1],blocks[2].to_i)
							end
						end
						for i in (3..blocks.length-2).step(2)
							if blocks[i+1][0]=="["
								eq = eq.send(blocks[i],varsILP[blocks[i+1][1].upcase])
							else
								eq = eq.send(blocks[i],blocks[i+1].to_i)
							end
						end
						m.enforce(eq)
					end
					
					p = m.to_problem
					p.solve

					if p.proven_infeasible?
						p "infeasible"
						@question.errors.add(:Answer, :infeasible)
					end
				end
			end
			
			if duplicateTitle
				@question.errors.add(:Title, :duplicate)
			end
			
			respond_to do |format|
				if @question.errors.any?
					if answer!=nil
						@positions1 = []
						@positions2 = []
						@values = []

						indx= -1
						while (indx= @question.Answer.index("〔", indx+ 1))
						@positions1 << indx
						end

						indx= -1
						while (indx= @question.Answer.index("〕", indx+ 1))
							@positions2 << indx
						end
						
						while (@positions1.length < 4)
							@positions1 << -1
							@positions2 << -1
						end
						if @question.Type == "FRM"
							text= @question.Answer[@question.Answer.index("〘")..-1]
							positionsComma = []
							positionsEB = []
							indx= -1
							while (indx= text.index(",", indx+ 1))
								positionsComma << indx
							end
							indx= -1
							while (indx= text.index("〙", indx+ 1))
								positionsEB << indx
							end
							for i in 0..positionsComma.length/2-1
								var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
								@values << var
							end
						end
					format.html { render :edit, status: :unprocessable_entity }
					format.json { render json: @question.errors, status: :unprocessable_entity }
					end
				else
					if @question.update(question_params.merge(:Options => options, :Answer => answer))
						format.html { redirect_to @question
												flash[:info] = 'Question was successfully updated.' }
						format.json { render :show, status: :ok, location: @question }
					else
						if answer!=nil
							@positions1 = []
							@positions2 = []
							@values = []

							indx= -1
							while (indx= @question.Answer.index("〔", indx+ 1))
							@positions1 << indx
							end

							indx= -1
							while (indx= @question.Answer.index("〕", indx+ 1))
								@positions2 << indx
							end
							
							while (@positions1.length < 4)
								@positions1 << -1
								@positions2 << -1
							end
							if @question.Type == "FRM"
								text= @question.Answer[@question.Answer.index("〘")..-1]
								positionsComma = []
								positionsEB = []
								indx= -1
								while (indx= text.index(",", indx+ 1))
									positionsComma << indx
								end
								indx= -1
								while (indx= text.index("〙", indx+ 1))
									positionsEB << indx
								end
								for i in 0..positionsComma.length/2-1
									var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
									@values << var
								end
							end
						end
						format.html { render :edit, status: :unprocessable_entity }
						format.json { render json: @question.errors, status: :unprocessable_entity }
					end
				end
			end
		end
  end

  # DELETE /questions/1 or /questions/1.json
  def destroy
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			@question.destroy
			respond_to do |format|
				format.html { redirect_back(fallback_location: assessments_url)
										flash[:info] = 'Question was successfully deleted.' }
				format.json { head :no_content }
			end
		end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      assessment = Assessment.find(@question.assessment_id)
			@user = User.find(assessment.user_id)
    end
		
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:assessment_id, :Title, :Text, :Feedback, :Type, :Points, :Answer, :Options)
    end
end
