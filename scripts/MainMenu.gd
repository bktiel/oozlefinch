extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Global").random=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_btnNewGame_pressed():
	get_node("/root/Global").difficulty=$Panel/optDifficulty.selected
	get_node("/root/Global").difficultyString=$Panel/optDifficulty.text
	get_tree().change_scene("res://levels/main.tscn")


func _on_btnQuit_pressed():
	get_tree().quit()


func _on_optRand_toggled(button_pressed):
	get_node("/root/Global").random=button_pressed
