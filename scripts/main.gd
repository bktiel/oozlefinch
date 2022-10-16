extends Node2D


var difficulty
var random=1
var lastIndex=0
export(PackedScene) var missile_scene
export(PackedScene) var helicopter_scene

var paused=false
var score=0
var cycles=0
var incoming = []
var questions = []
# stores repetition
var usedQuestionIndices=[]

# manual mode
var manualMode=false

var target=null
var targets=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	random=get_node("/root/Global").random
	difficulty=get_node("/root/Global").difficulty
	randomize()
	if(difficulty==3):
		manualMode=true
		difficulty=0
	print("new game")
	new_game() 

func new_game():
	randomize()
	$GUI/filter.hide()
	$GUI/panGameOver.hide()
	$level/MissileTimer.wait_time-=difficulty
	if(difficulty==2):
		$GUI/Threat.max_value=4
	# reset vars
	incoming=[]
	targets=[]
	target=null
	score=0
	cycles=0
	$GUI/CityHealth.max_value-=difficulty
	#print($GUI/CityHealth.max_value)
	$level/City1.health=$GUI/CityHealth.max_value
	$GUI/CityHealth.value=$GUI/CityHealth.max_value
	$level/Player.start($level/playerStart.position)
	
	if(manualMode):
		# ugly
		$GUI/AnswerPanel/lblAnswer1.hide()
		$GUI/AnswerPanel/lblAnswer2.hide()
		$GUI/AnswerPanel/lblAnswer3.hide()
		$GUI/AnswerPanel/lblAnswer4.hide()
		
		$GUI/AnswerPanel/txtAnswer.show()
		
	$level/AudioStreamPlayer.play(0)
	print("starting timer")
	questions=load_questions()
	for i in range(questions.size()):
		usedQuestionIndices.push_back(0)
	$level/StartTimer.start()
	
# return indices of array that contain value
func get_indices_with_value(arr,value):
	var ret=[]
	for i in arr.size():
		if arr[i]==value:
			ret.push_back(i)
	return ret
			
	
func get_question():
	var questionIndex=null	
	if(random):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		#print(usedQuestionIndices)
		
		var desiredUsageCount=0	
		while(questionIndex==null):
			var validIndices=get_indices_with_value(usedQuestionIndices,desiredUsageCount)
			if validIndices.size()<1:
				desiredUsageCount+=1
				continue
			# otherwise have a selection
			questionIndex=validIndices[floor(rng.randf_range(0,validIndices.size()))]
		# update
		usedQuestionIndices[questionIndex]+=1
	else:
		questionIndex=lastIndex
		lastIndex=(lastIndex+1)%questions.size()
	var question=questions[questionIndex]
	var missile=launch_TBM(questionIndex)
	#pendingQuestions.append([questionIndex,missile])
	
	
func launch_TBM(index=0):
	var missile_location
	var direction
	var missile= missile_scene.instance()
	missile.get_node("labelHolder").get_node("lblQuery").text=questions[index][0]
	missile.questionIndex=index
	var side=randf()*2
	
	missile.connect("clicked", self, "threat_clicked")
	missile.connect("explode", self, "remove_target")

	if side<=1:
		missile_location=$level/East.position
		missile_location.x-=rand_range(1,50)
		direction = 0+ (PI / 4)*1
	else:
		missile_location=$level/West.position
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
	$level.add_child(missile)
	incoming.push_back(missile)
	return missile
	
func launch_ABT(index=0):
	var helo=helicopter_scene.instance()
	# set question
	helo.questionIndex=index
	
	helo.transform=$level/heloEast.transform
	helo.scale=Vector2(0.6,0.6)
	helo.goal_x=$level/heloWest.position.x
	# set gun orientation
	
	helo.get_node("labelHolder").get_node("lblQuery").text=questions[index][0]
	helo.connect("clicked", self, "threat_clicked")
	helo.connect("reached_goal", self, "helo_reached_goal")
	helo.connect("shoot", self, "helo_shoot")
	helo.connect("explode", self, "remove_target")
	$level.add_child(helo)
	
	for gun in helo.get_node("guns").get_children():
		gun.look_at($level/heloShootRef.position)
	incoming.push_back(helo)
	return helo
	
# helo has reached goal and will turn around
func helo_reached_goal(helo):
	if(!is_instance_valid(helo)):
		return
	if(helo.goal_x==$level/heloEast.position.x):
		helo.goal_x=$level/heloWest.position.x
	else:
		helo.goal_x=$level/heloEast.position.x
		
	for gun in helo.get_node("guns").get_children():
		gun.look_at($level/heloShootRef.position)
	
func helo_shoot(helo):
	# fire everything
	for gun in helo.get_node("guns").get_children():
		if(!is_instance_valid(gun)):
			break
		var Bullet = preload("res://actors/Bullet.tscn")
		var b = Bullet.instance()
		add_child(b)
		play_sound(b.position,"m2")
		b.start(gun.global_transform)
		yield(get_tree().create_timer(0.2), "timeout")		
	
func threat_clicked(id):
	var threat=instance_from_id(id)
	if(target==threat):
		return
	target=threat
	# set reticle
	$GUI/reticle.show()
	if($GUI/lblInstructions.visible):
		$GUI/lblInstructions.hide()
	$GUI/reticle.target=threat
	$GUI/AnswerPanel.set_question_answers(questions,threat)
	
func remove_target(target):
	if(is_instance_valid(target)):
		incoming.erase(target)
		# play sound
		play_sound(target.position,"explode")
		if($GUI/reticle.target==target):
			$GUI/reticle.target=null
			$GUI/reticle.hide()
	
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
	# nuke
	#if Input.is_action_pressed("nuke"):
	#	print('thaad')
	#	for threat in incoming:
	#		if(threat.get_class()=="Missile"):
	#			print('engaging')
	#			$level/SecretPatriot.fire(threat)

	if(!is_instance_valid($GUI/reticle.target)):
		$GUI/AnswerPanel.clear_buttons()
	for threat in incoming:
		if(!is_instance_valid(threat)):
			continue
		if threat.get_class()=="Hind":
			if((threat.position.x<$level/Patriot2.position.x or
			threat.position.x>$level/Patriot.position.x)):
				threat.shooting=false
				if(threat.shots<5):
					threat.shots=5
			else:
				threat.shooting=true
				threat.begin_shoot=floor(randi()%50)


func game_over():
	$level/AudioStreamPlayer.stop()
	$level/MissileTimer.stop()
	$GUI/reticle.hide()
	# this is a dumb way to do it but w/e
	for eny in incoming:
		if(is_instance_valid(eny)):
			eny.queue_free()
	$GUI/panGameOver.show()
	$GUI/panGameOver/lblScore.text=str(score)
	$GUI/panGameOver/lblDifficulty.text=get_node("/root/Global").difficultyString
	if(!random):
		$GUI/panGameOver/lblDifficulty.text=$GUI/panGameOver/lblDifficulty.text+" (seq)"
	

func _on_StartTimer_timeout():
	
	print("start missile timer")
	get_question()
	$level/MissileTimer.start()

func _on_MissileTimer_timeout():
	
	cycles+=1
	$level/MissileTimer.wait_time=clamp($level/MissileTimer.wait_time-(cycles/40),3,100)
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
		$level/Player.firing=true
	else:
		if $level/Player.last_side==0:
			$level/Player.goal_x=$level/Patriot2.position.x
			$level/Player.last_side=1
		else:
			$level/Player.goal_x=$level/Patriot.position.x
			$level/Player.last_side=0
		$level/Player.firing=true
		


func _on_Player_launcher_reached(launcher):
	if($level/Player.shocked):
		return
	# fire at first target
	if(!targets.empty()):
		play_sound(launcher.position,"launch",-0.8)
		var thisTarget=targets.front()
		if(is_instance_valid(thisTarget)):
			launcher.fire(thisTarget)
		targets.erase(thisTarget)
		if(targets.empty()):
			$level/Player.firing=false
		else:
			engage()
	else:
		$level/Player.firing=false

# city damaged, update HP
func _on_City1_city_damaged():
	# show filter
	$GUI/damagefilter.show()
	position.y-=10
	play_sound($level/City1.position,"explode")
	$GUI/CityHealth.value-=1
	yield(get_tree().create_timer(0.15), "timeout")
	position.y+=10
	$GUI/damagefilter.hide()
	
	if $level/City1.health<1:
		$GUI/CityHealth.hide()
		$GUI/filter.show()
		game_over()

func update_score(newScore):
	score=newScore
	$GUI/lblScoreLabel/lblScore.text="%d"%score

func _on_City1_city_destroyed():
	pass
	

func _sound_complete(node):
	node.stop()
	node.queue_free()

# launch
func _on_AnswerPanel_correct_response(thisThreat):
	if(is_instance_valid(thisThreat)):
		targets.append(thisThreat)
		engage()
	$GUI/AnswerPanel.clear_buttons()

func _on_AnswerPanel_bad_response():
	if(!$GUI/Threat.visible):
		$GUI/Threat.show()
	$GUI/Threat.value+=1
	play_sound($level/City1.position,"oof",1)
	# bad
	if($GUI/Threat.value==$GUI/Threat.max_value):
		launch_ABT(floor(randi()%questions.size()))
		$GUI/Threat.value=0
		play_sound($level/heloEast.position,"alert",1)
		$GUI/Threat.hide()
		

func _on_locAudio_finished():
	pass # Replace with function body.


func _on_btnRestart_pressed():
	get_tree().change_scene("res://levels/main.tscn")


func _on_btnMenu_pressed():
	get_tree().change_scene("res://MainMenu.tscn")	


func handle_interception():
	if(!$GUI/lblScoreLabel.visible):
		$GUI/lblScoreLabel.show()
	update_score(score+1)


func _on_Patriot_fire_missile(launcher, thisTarget):
	var missile=launcher.projectile.instance()
	launcher.add_child(missile)
	# events
	missile.connect("intercepted",self,"handle_interception")
	
	if(launcher.direction==launcher.LAUNCHER_ORIENTATION.left):
		missile.start(launcher.get_node("LaunchPointLeft").get_global_transform(),thisTarget)
	else:
		missile.start(launcher.get_node("LaunchPointRight").get_global_transform(),thisTarget)
