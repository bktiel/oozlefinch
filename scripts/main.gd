extends Node2D


var score=0
var difficulty
export(PackedScene) var missile_scene
export(PackedScene) var helicopter_scene


var cycles=0

var incoming = []
var questions = []

var target=null
var targets=[]

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
	if(difficulty==2):
		$Threat.max_value=4
	# reset vars
	incoming=[]
	targets=[]
	target=null
	score=0
	cycles=0
	$CityHealth.max_value-=difficulty
	$City1.health=$CityHealth.max_value
	$CityHealth.value=$CityHealth.max_value
	$Player.start($playerStart.position)
	

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
	
func launch_ABT(index=0):
	var helo=helicopter_scene.instance()
	# set question
	helo.questionIndex=index
	
	helo.transform=$heloEast.transform
	helo.scale=Vector2(0.6,0.6)
	helo.goal_x=$heloWest.position.x
	# set gun orientation
	
	helo.get_node("labelHolder").get_node("lblQuery").text=questions[index][0]
	helo.connect("clicked", self, "threat_clicked")
	helo.connect("reached_goal", self, "helo_reached_goal")
	helo.connect("shoot", self, "helo_shoot")
	helo.connect("explode", self, "remove_target")
	add_child(helo)
	
	for gun in helo.get_node("guns").get_children():
		gun.look_at($heloShootRef.position)
	incoming.push_back(helo)
	return helo
	
# helo has reached goal and will turn around
func helo_reached_goal(helo):
	if(!is_instance_valid(helo)):
		return
	if(helo.goal_x==$heloEast.position.x):
		helo.goal_x=$heloWest.position.x
	else:
		helo.goal_x=$heloEast.position.x
		
	for gun in helo.get_node("guns").get_children():
		gun.look_at($heloShootRef.position)
	
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
	$reticle.show()
	if($lblInstructions.visible):
		$lblInstructions.hide()
	$reticle.target=threat
	$AnswerPanel.set_question_answers(questions,threat.questionIndex)
	
func remove_target(target):
	if(is_instance_valid(target)):
		incoming.erase(target)
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
	if(!is_instance_valid($reticle.target)):
		$AnswerPanel.clear_buttons()
	for threat in incoming:
		if(!is_instance_valid(threat)):
			continue
		if threat.get_class()=="Hind":
			if((threat.position.x<$Patriot2.position.x or
			threat.position.x>$Patriot.position.x)):
				threat.shooting=false
				if(threat.shots<5):
					threat.shots=5
			else:
				threat.shooting=true
				threat.begin_shoot=floor(randi()%50)
	#if(pendingQuestions.size()>0 and $AnswerPanel.question==-1):
	#	$AnswerPanel.set_question_answers(questions,pendingQuestions.front()[0])
	
func game_over():
	$AudioStreamPlayer.stop()
	$MissileTimer.stop()
	$reticle.hide()
	# this is a dumb way to do it but w/e
	for eny in incoming:
		if(is_instance_valid(eny)):
			eny.queue_free()
	$panGameOver.show()
	$panGameOver/lblScore.text=str(score)
	$panGameOver/lblDifficulty.text=get_node("/root/Global").difficultyString
	

func _on_StartTimer_timeout():
	
	print("start missile timer")
	get_question()
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
	if($Player.shocked):
		return
	# fire at first target
	if(targets.size()>0):
		play_sound(launcher.position,"launch",-0.8)
		var target=targets.front()
		if(is_instance_valid(target)):
			launcher.fire(target)
		targets.erase(target)
		if(targets.empty()):
			$Player.firing=false
		else:
			engage()

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

func update_score(newScore):
	score=newScore
	$lblScoreLabel/lblScore.text="%d"%score

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

func _on_AnswerPanel_bad_response():
	if(!$Threat.visible):
		$Threat.show()
	$Threat.value+=1
	play_sound($Player.position,"oof")
	# bad
	if($Threat.value==$Threat.max_value):
		launch_ABT(floor(randi()%questions.size()))
		$Threat.value=0
		play_sound($heloEast.position,"alert",1)
		$Threat.hide()
		

func _on_locAudio_finished():
	pass # Replace with function body.


func _on_btnRestart_pressed():
	get_tree().change_scene("res://levels/main.tscn")


func _on_btnMenu_pressed():
	get_tree().change_scene("res://MainMenu.tscn")	


func handle_interception():
	if(!$lblScoreLabel.visible):
		$lblScoreLabel.show()
	update_score(score+1)


func _on_Patriot_fire_missile(launcher):
	var missile=launcher.projectile.instance()
	launcher.add_child(missile)
	# events
	missile.connect("intercepted",self,"handle_interception")
	
	if(launcher.direction==launcher.LAUNCHER_ORIENTATION.left):
		missile.start(launcher.get_node("LaunchPointLeft").get_global_transform(),target)
	else:
		missile.start(launcher.get_node("LaunchPointRight").get_global_transform(),target)
