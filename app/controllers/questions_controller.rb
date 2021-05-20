class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit update destroy ]
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	skip_before_action :admin_user

  # GET /questions/1 or /questions/1.json
	# prepares data for question details page
  def show
		# check if page should be accessed
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		end
  end

  # GET /questions/new
	# prepares data for new question page
  def new
		assessment = Assessment.find(params[:assessment_id])
		user = User.find(assessment.user_id)
		# check if page should be accessed
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
	# prepares data for edit question page
  def edit
		# check if page should be accessed
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			@positions1 = []
			@positions2 = []
			@values = []
			# if assessment id was provided 
			if params[:assessment_id]
				@question.assessment_id = params[:assessment_id]
			# or question was provided
			elsif params[:question]
				@question.assessment_id = params[:question][:assessment_id]
			end 
			# find the index of all 〔
			indx= -1
			while (indx= @question.Answer.index("〔", indx+ 1))
				@positions1 << indx
			end
			# find the index of all 〕
			indx= -1
			while (indx= @question.Answer.index("〕", indx+ 1))
				@positions2 << indx
			end
			
			# if less that 4 found fill the rest with -1
			while (@positions1.length < 4)
				@positions1 << -1
				@positions2 << -1
			end
			
			# if formula question
			if @question.Type == "FRM"
				# get the tails of the string containing intervals and constraints
				text= @question.Answer[@question.Answer.index("〘")..-1]
				positionsComma = []
				positionsEB = []
				# find the splitting comas
				indx= -1
				while (indx= text.index(",", indx+ 1))
					positionsComma << indx
				end
				# find the string end of each variable or constraint
				indx= -1
				while (indx= text.index("〙", indx+ 1))
					positionsEB << indx
				end
				# get the value interval for each variable
				for i in 0..positionsComma.length/2-1
					var = [text[positionsComma[2*i]+1..positionsComma[2*i+1]-1].to_i,text[positionsComma[2*i+1]+1..positionsEB[i]-1].to_i]
					@values << var
				end
			end
		end
  end

  # POST /questions or /questions.json
	# creates and saves a new question
  def create
		assessment = Assessment.find(params[:question][:assessment_id])
		user = User.find(assessment.user_id)
		# check if  user should be able to create a new question
		if !logged_in? || (!admin? && !(current_user == user))
		naughty_user
		else
			options=""
			answer=""
			questions = Question.where(assessment_id: params[:question][:assessment_id])
			duplicateTitle = false
			# check if title is duplicate
			for question in questions
				if question.Title == params[:question][:Title]
					duplicateTitle = true
				end
			end
			#form the options string according to type
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
			#form the answer string according to type
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
				res = formula.scan(/([\[][A-Z]+[\]])/) # get all the variables
				# for each variable
				for var in res
					# get name
					tag=var[0][1..var[0].length-2].upcase
					# get interval
					vars[tag]=[params[(tag+"Min").intern].to_i,params[(tag+"Max").intern].to_i]
					# add to answer
					answer = answer + "〘" + tag + "," + vars[tag][0].to_s + "," + vars[tag][1].to_s + "〙"
				end
				relationsRegex= /\A((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+)((,| ,|, | , )((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+))*\Z/
				formulaRegex= /((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)/
				relations = params[:FRMRelations]
				# if no relations
				if relations == nil
				 relations = ""
				end
				test = formula.scan(formulaRegex) #test formula for valid format
				test1 = relations.match(relationsRegex) #test relations for valid format
				test2 = relations.scan(/([\[][A-Z]+[\]])/) #test for foreign variables
				foreignVars = false
				# for each variable in relations
				for var in test2
					tag=var[0][1..var[0].length-2].upcase
					# if variable not in variables list
					if !vars.key?(tag)
						foreignVars = true
					end
				end
				# if any format problem occurs
				if (test1 == nil && relations.length != 0) || foreignVars || test.length == 0
					answer=""
				elsif relations.length != 0
					answer = answer + "〚" + relations + "〛"
				end
				# form ILP problem
				m = Cbc::Model.new
				rels=[]
				# for each relation fix the syntax
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
				# if no problems so far
				if answer.length != 0
					varsILP={}
					maximize=0
					# create each variable for the ILP optimization equation
					for var in vars
						varsILP[var[0]]=m.int_var(var[1][0]..var[1][1])
						sign=rand(1..2)
						if sign == 1
							maximize = maximize + rand(1..20) * varsILP[var[0]]
						elsif sign == 2
							maximize = maximize - rand(1..20) * varsILP[var[0]]
						end
					end
					# set the maximization equation
					m.maximize(maximize)
					# for each relation
					for rel in rels
						eq=0
						blocks=rel.split()
						# build it
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
						# enforce it
						m.enforce(eq)
					end
					
					# solve the problem
					p = m.to_problem
					p.solve
					
					# if infeasible
					if p.proven_infeasible?
						infeasible = true
					else
						infeasible = false
					end
				end
			end
			
			@question = Question.new(question_params.merge(:Options => options, :Answer => answer))
			respond_to do |format|
			# if title already used
			if duplicateTitle
				@question.errors.add(:Title, :duplicate)
			end
			# if infeasible
			if infeasible
				@question.errors.add(:Answer, :infeasible)
			end
				# if any other error
				if @question.errors.any?
					# if there was an answer prepare it for the page load
					if answer!=nil
						@positions1 = []
						@positions2 = []
						@values = []

						# find the index of all 〔
						indx= -1
						while (indx= @question.Answer.index("〔", indx+ 1))
						@positions1 << indx
						end
						# find the index of all 〕
						indx= -1
						while (indx= @question.Answer.index("〕", indx+ 1))
							@positions2 << indx
						end
						# if less that 4 found fill the rest with -1
						while (@positions1.length < 4)
							@positions1 << -1
							@positions2 << -1
						end
						# if formula question
						if @question.Type == "FRM"
							# get the tails of the string containing intervals and constraints
							text= @question.Answer[@question.Answer.index("〘")..-1]
							positionsComma = []
							positionsEB = []
							# find the splitting comas
							indx= -1
							while (indx= text.index(",", indx+ 1))
								positionsComma << indx
							end
							# find the string end of each variable or constraint
							indx= -1
							while (indx= text.index("〙", indx+ 1))
								positionsEB << indx
							end
							# get the value interval for each variable
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
						# if there was an answer prepare it for the page load
						if answer!=nil
							@positions1 = []
							@positions2 = []
							@values = []
							# find the index of all 〔
							indx= -1
							while (indx= @question.Answer.index("〔", indx+ 1))
							@positions1 << indx
							end
							# find the index of all 〕
							indx= -1
							while (indx= @question.Answer.index("〕", indx+ 1))
								@positions2 << indx
							end
							# if less that 4 found fill the rest with -1
							while (@positions1.length < 4)
								@positions1 << -1
								@positions2 << -1
							end
							# if formula question
							if @question.Type == "FRM"
								# get the tails of the string containing intervals and constraints
								text= @question.Answer[@question.Answer.index("〘")..-1]
								positionsComma = []
								positionsEB = []
								# find the splitting comas
								indx= -1
								while (indx= text.index(",", indx+ 1))
									positionsComma << indx
								end
								# find the string end of each variable or constraint
								indx= -1
								while (indx= text.index("〙", indx+ 1))
									positionsEB << indx
								end
								# get the value interval for each variable
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
	# updates and saves a question
  def update
		# check if  user should be able to create a new question
		if !logged_in? || (!admin? && !(current_user == @user))
		naughty_user
		else
			options=""
			answer=""
			questions = Question.where(assessment_id: params[:question][:assessment_id])
			duplicateTitle = false
			# check if title is duplicate
			for question in questions
				if question.Title == params[:question][:Title] && question.id != params[:id].to_i
					duplicateTitle = true
				end
			end
			#form the options string according to type
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
			#form the answer string according to type
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
				res = formula.scan(/([\[][A-Z]+[\]])/) # get all the variables
				# for each variable
				for var in res
					# get name
					tag=var[0][1..var[0].length-2].upcase
					# get interval
					vars[tag]=[params[(tag+"Min").intern].to_i,params[(tag+"Max").intern].to_i]
					# add to answer
					answer = answer + "〘" + tag + "," + vars[tag][0].to_s + "," + vars[tag][1].to_s + "〙"
				end
				relationsRegex= /\A((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+)((,| ,|, | , )((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)(<=|>=|=)([0-9]+))*\Z/
				formulaRegex= /((([\[][A-Z]+[\]])|[0-9]+)((\+|\-|\/|\*)(([\[][A-Z]+[\]])|[0-9]+))*)/
				# if relations parameter
				if params[:FRMRelations]
					relations = params[:FRMRelations]
				else	
					relations = ""
				end
				test = formula.scan(formulaRegex) #test formula for valid format
				test1 = relations.match(relationsRegex) #test relations for valid format
				test2 = relations.scan(/([\[][A-Z]+[\]])/) #test for foreign variables
				foreignVars = false
				# for each variable in relations
				for var in test2
					tag=var[0][1..var[0].length-2].upcase
					# if variable not in variables list
					if !vars.key?(tag)
						foreignVars = true
					end
				end
				# if any format problem occurs
				if (test1 == nil && relations.length != 0) || foreignVars || test.length == 0
					answer=""
				elsif relations.length != 0
					answer = answer + "〚" + relations + "〛"
				end
				# form ILP problem
				m = Cbc::Model.new
				p relations
				rels=[]
				# for each relation fix the syntax
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
				# if no problems so far
				if answer.length != 0
					varsILP={}
					maximize=0
					# create each variable for the ILP optimization equation
					for var in vars
						varsILP[var[0]]=m.int_var(var[1][0]..var[1][1])
						sign=rand(1..2)
						if sign == 1
							maximize = maximize + rand(1..20) * varsILP[var[0]]
						elsif sign == 2
							maximize = maximize - rand(1..20) * varsILP[var[0]]
						end
					end
					# set the maximization equation
					m.maximize(maximize)
					# for each relation
					for rel in rels
						eq=0
						blocks=rel.split()
						# build it
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
						# enforce it
						m.enforce(eq)
					end
					
					# solve the problem
					p = m.to_problem
					p.solve

					# if infeasible
					if p.proven_infeasible?
						p "infeasible"
						@question.errors.add(:Answer, :infeasible)
					end
				end
			end
			
			# if title already used
			if duplicateTitle
				@question.errors.add(:Title, :duplicate)
			end
			
			respond_to do |format|
				# if any other error
				if @question.errors.any?
					# if there was an answer prepare it for the page load
					if answer!=nil
						@positions1 = []
						@positions2 = []
						@values = []

						# find the index of all 〔
						indx= -1
						while (indx= @question.Answer.index("〔", indx+ 1))
						@positions1 << indx
						end
						# find the index of all 〕
						indx= -1
						while (indx= @question.Answer.index("〕", indx+ 1))
							@positions2 << indx
						end
						# if less that 4 found fill the rest with -1
						while (@positions1.length < 4)
							@positions1 << -1
							@positions2 << -1
						end
						# if formula question
						if @question.Type == "FRM"
							# get the tails of the string containing intervals and constraints
							text= @question.Answer[@question.Answer.index("〘")..-1]
							positionsComma = []
							positionsEB = []
							# find the splitting comas
							indx= -1
							while (indx= text.index(",", indx+ 1))
								positionsComma << indx
							end
							# find the string end of each variable or constraint
							indx= -1
							while (indx= text.index("〙", indx+ 1))
								positionsEB << indx
							end
							# get the value interval for each variable
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
						# if there was an answer prepare it for the page load
						if answer!=nil
							@positions1 = []
							@positions2 = []
							@values = []
							# find the index of all 〔
							indx= -1
							while (indx= @question.Answer.index("〔", indx+ 1))
							@positions1 << indx
							end
							# find the index of all 〕
							indx= -1
							while (indx= @question.Answer.index("〕", indx+ 1))
								@positions2 << indx
							end
							# if less that 4 found fill the rest with -1
							while (@positions1.length < 4)
								@positions1 << -1
								@positions2 << -1
							end
							# if formula question
							if @question.Type == "FRM"
								# get the tails of the string containing intervals and constraints
								text= @question.Answer[@question.Answer.index("〘")..-1]
								positionsComma = []
								positionsEB = []
								# find the splitting comas
								indx= -1
								while (indx= text.index(",", indx+ 1))
									positionsComma << indx
								end
								# find the string end of each variable or constraint
								indx= -1
								while (indx= text.index("〙", indx+ 1))
									positionsEB << indx
								end
								# get the value interval for each variable
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
	# removes a a question
  def destroy
		# check if user should be able to remove this question
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
    # callback to load the assessment creator
    def set_user
      assessment = Assessment.find(@question.assessment_id)
			@user = User.find(assessment.user_id)
    end
		
    # callback to load the question
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:assessment_id, :Title, :Text, :Feedback, :Type, :Points, :Answer, :Options)
    end
end
