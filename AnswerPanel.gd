extends Panel


var selected=0
var correct=0
var question=-1
signal correct_response(ID)

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


func set_question_answers(array,row_index):
	clear_buttons()
	randomize()
	var used_answers=[]
	# set prompt
	$lblPrompt.text=array[row_index][0]
	# set correct answer
	correct=floor(randi()%4)
	print(correct)
	question=row_index
	var labels=get_children()
	used_answers.push_back(row_index)
	# others
	for i in range(4):
		if i==correct:
			labels[i].text="%d) %s " % [i+1,array[row_index][1]]
			continue
		var falseAnswer=floor(randi()%array.size())
		while(used_answers.has(falseAnswer)):
			randomize()
			falseAnswer=floor(randi()%array.size())
		used_answers.push_back(falseAnswer)
		labels[i].text="%d) %s " % [i+1,array[falseAnswer][1]]

func reset_buttons():
	for i in range(4):
		self.get_children()[i].pressed=false
		
func clear_buttons():
	$lblPrompt.text=""
	for i in range(4):
		self.get_children()[i].pressed=false
		self.get_children()[i].text="..."
			
func _on_lblAnswer1_pressed():
	reset_buttons()
	$lblAnswer1.pressed=true	
	selected=0

func _on_lblAnswer2_pressed():
	reset_buttons()
	$lblAnswer2.pressed=true	
	selected=1

func _on_lblAnswer3_pressed():
	reset_buttons()
	$lblAnswer3.pressed=true	
	selected=2

func _on_lblAnswer4_pressed():
	reset_buttons()
	$lblAnswer4.pressed=true	
	selected=3


func _on_btnEngage_pressed():
	if(selected==correct):
		clear_buttons()
		emit_signal("correct_response",question)
		question=-1
		

