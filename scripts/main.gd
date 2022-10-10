extends Node2D


var score=0
var difficulty
export(PackedScene) var missile_scene

var cycles=0

var incoming = []
var questions = []
#var pendingQuestions=[]


var target=null
var targets=[]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	difficulty=get_node("/root/Global").difficulty
	randomize()
	print("new game")
	new_game() 

func new_game():
	randomize()
	$filter.hide()
	$panGameOver.hide()
	$MissileTimer.wait_time-=difficulty
	# reset vars
	incoming=[]
	targets=[]
	target=null
	score=0
	cycles=0
	$City1.health=5
	$CityHealth.value=5
	$Player.start($playerStart.position)
	
	#var altChance=ceil(randi()%3)
	#if altChance<=1:
	#	var stream=load("res://music/%s.ogg"%"funky")
	#	$AudioStreamPlayer.set_stream(stream)
	$AudioStreamPlayer.play(0)
	print("starting timer")
	questions=load_questions()
	$StartTimer.start()
	
	
func get_question():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var questionIndex=floor(rng.randf_range(0,questions.size()))
	#print(questions[questionIndex][0],questions[questionIndex][1])	
	var question=questions[questionIndex]
	var missile=launch_TBM(questionIndex)
	#pendingQuestions.append([questionIndex,missile])
	
	
func launch_TBM(index=""):
	var missile_location
	var direction
	var missile= missile_scene.instance()
	missile.get_node("labelHolder").get_node("lblQuery").text=questions[index][0]
	missile.questionIndex=index
	var side=randf()*2
	
	missile.connect("clicked", self, "missile_clicked")
	missile.connect("explode", self, "remove_target")
	

	if side<=1:
		missile_location=$East.position
		missile_location.x-=rand_range(1,50)
		direction = 0+ (PI / 4)*1
	else:
		missile_location=$West.position
		missile_location.x+=rand_range(1,50)
		direction = 0 - (PI/4)*1
	# set position
	missile.position = missile_location
	missile.rotation = direction
	# give velocity
	#var velocity = Vector2(rand_range(15, 20.0), 0.0)
	#missile.linear_velocity = velocity.rotated(direction)
	missile.set_applied_force(Vector2(0,0.08*(difficulty+1)+(0.1*cycles/100)).rotated(missile.rotation))
	# add
	add_child(missile)
	incoming.push_back(missile)
	return missile
	
func missile_clicked(id):
	var missile=instance_from_id(id)
	if(target==missile):
		return
	target=missile
	# set reticle
	$reticle.show()
	if($lblInstructions.visible):
		$lblInstructions.hide()
	$reticle.target=missile
	$AnswerPanel.set_question_answers(questions,missile.questionIndex)
	
func remove_target(target):
	if(is_instance_valid(target)):
		incoming.erase(target)
		score+=1		
		# play sound
		play_sound(target.position,"explode")
		if($reticle.target==target):
			$reticle.target=null
			$reticle.hide()
	
func play_sound(position,audio,volume=0):
	var new_node=AudioStreamPlayer2D.new()
	new_node.position=position
	var stream=load("res://music/%s.ogg"%audio)
	new_node.set_stream(stream)
	new_node.set_volume_db(volume)
	new_node.connect("finished",self,"_sound_complete",[new_node])
	add_child(new_node)
	new_node.play(0)

func _process(delta):
	pass
	#if(pendingQuestions.size()>0 and $AnswerPanel.question==-1):
	#	$AnswerPanel.set_question_answers(questions,pendingQuestions.front()[0])
	
func game_over():
	$AudioStreamPlayer.stop()
	$MissileTimer.stop()
	# this is a dumb way to do it but w/e
	for eny in incoming:
		if(is_instance_valid(eny)):
			eny.queue_free()
	$panGameOver.show()
	$panGameOver/lblScore.text=str(score)
	$panGameOver/lblDifficulty.text=get_node("/root/Global").difficultyString
	

func _on_StartTimer_timeout():
	print("start missile timer")
	$MissileTimer.start()

func _on_MissileTimer_timeout():
	cycles+=1
	$MissileTimer.wait_time=clamp($MissileTimer.wait_time-(cycles/40),2,100)
	get_question()
	
func load_questions():
	var csv=[]
	var file = File.new()
	file.open("res://tabs.csv", File.READ)
	while !file.eof_reached():
		var row=file.get_csv_line()
		csv.append(row)
	file.close()
	csv.pop_back()
	return csv
	

	

func engage():
	var side=randf()*5
	if side<=1:
		$Player.firing=true
	else:
		if $Player.last_side==0:
			$Player.goal_x=$Patriot2.position.x
			$Player.last_side=1
		else:
			$Player.goal_x=$Patriot.position.x
			$Player.last_side=0
		$Player.firing=true
		


func _on_Player_launcher_reached(launcher):
	# fire at first target
	if(targets.size()>0):
		play_sound(launcher.position,"launch",-0.8)
		launcher.fire(targets.front())
		targets.remove(0)
		$Player.firing=false

# city damaged, update HP
func _on_City1_city_damaged():
	# show filter
	$damagefilter.show()
	position.y-=10
	play_sound($City1.position,"explode")
	$CityHealth.value-=1
	yield(get_tree().create_timer(0.15), "timeout")
	position.y+=10
	$damagefilter.hide()
	
	if $City1.health<1:
		$CityHealth.hide()
		$filter.show()
		game_over()


func _on_City1_city_destroyed():
	pass
	

func _sound_complete(node):
	node.stop()
	node.queue_free()

# launch
func _on_AnswerPanel_correct_response(ID):
	if(is_instance_valid(target)):
		targets.append(target)
		engage()
	$AnswerPanel.clear_buttons()


func _on_locAudio_finished():
	pass # Replace with function body.


func _on_btnRestart_pressed():
	get_tree().change_scene("res://levels/main.tscn")


func _on_btnMenu_pressed():
	get_tree().change_scene("res://MainMenu.tscn")	
