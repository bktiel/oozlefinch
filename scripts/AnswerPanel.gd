extends Panel


var selected=0
var correct=0
var question=-1
var threat=null
signal correct_response(ID)
signal bad_response()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	
	if Input.is_action_pressed("option1"):
		_on_lblAnswer1_pressed()
	elif Input.is_action_pressed("option2"):
		_on_lblAnswer2_pressed()
	elif Input.is_action_pressed("option3"):
		_on_lblAnswer3_pressed()
	elif Input.is_action_pressed("option4"):
		_on_lblAnswer4_pressed()


func set_question_answers(array,thisThreat):
	var row_index=thisThreat.questionIndex
	threat=thisThreat
	# manual mode
	if(get_node("/root/Global").difficulty==4):
		$lblPrompt.text=array[row_index][0]
		correct=array[row_index][1]
		$txtAnswer.grab_focus()
		return
	clear_buttons()
	randomize()
	var used_answers=[]
	# set prompt
	$lblPrompt.text=array[row_index][0]
	# set correct answer
	correct=floor(randi()%3)
	print(correct)
	question=int(row_index)
	var labels=get_children()
	used_answers.push_back(question)
	print(used_answers)
	# others
	for i in range(4):
		
		if i==correct:
			labels[i].text="%d) %s " % [i+1,array[row_index][1]]
			continue
		var falseAnswer=int(floor(randi()%array.size()))
		while(used_answers.has(falseAnswer)):
			randomize()
			falseAnswer=int(floor(randi()%array.size()))
			print("new answer is %d" % falseAnswer)
		used_answers.push_back(falseAnswer)
		print(used_answers)
		labels[i].text="%d) %s " % [i+1,array[falseAnswer][1]]

func reset_buttons():
	for i in range(4):
		self.get_children()[i].pressed=false
		
func clear_buttons():
	if(get_node("/root/Global").difficulty==4):
		$txtAnswer.text=""
		$txtAnswer.release_focus()
	$lblPrompt.text=""
	for i in range(4):
		self.get_children()[i].pressed=false
		self.get_children()[i].text="..."
	$btnEngage.disabled=true	
	
			
func _on_lblAnswer1_pressed():
	reset_buttons()
	$lblAnswer1.pressed=true	
	selected=0
	$btnEngage.disabled=false

func _on_lblAnswer2_pressed():
	reset_buttons()
	$lblAnswer2.pressed=true	
	selected=1
	$btnEngage.disabled=false
	

func _on_lblAnswer3_pressed():
	reset_buttons()
	$lblAnswer3.pressed=true	
	selected=2
	$btnEngage.disabled=false
	

func _on_lblAnswer4_pressed():
	reset_buttons()
	$lblAnswer4.pressed=true	
	selected=3
	$btnEngage.disabled=false
	


func _on_btnEngage_pressed():
	print("pressed")
	# manual mode
	if(get_node("/root/Global").difficulty==4):
		selected=$txtAnswer.text.strip_edges()
	if(selected==correct):
		clear_buttons()
		emit_signal("correct_response",threat)
		question=-1
	else:
		if(question!=-1):
			emit_signal("bad_response")
		



func _on_txtAnswer_text_changed():
	selected=$txtAnswer.text
	$btnEngage.disabled=false
	# clumsy way to detect ENTER
	if("\n" in selected):
		$txtAnswer.text=$txtAnswer.text.strip_edges()
		_on_btnEngage_pressed()
