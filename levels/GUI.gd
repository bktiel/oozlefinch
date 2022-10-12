extends CanvasLayer

var paused=false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func pause():
	if(paused):
		get_tree().paused=false
		$AnswerPanel.show()
		$filter.hide()
		$lblPause.hide()
		paused=false
	else:
		get_tree().paused=true
		$AnswerPanel.hide()
		self.paused=false
		$filter.show()
		$lblPause.show()
		paused=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func _input(event):
	# inputs
	if event.is_action_pressed("pause"):
		pause()


func _on_btnRestart_pressed():
	if(paused):
		pause()
	get_tree().change_scene("res://levels/main.tscn")


func _on_btnMenu_pressed():
	if(paused):
		pause()
	get_tree().change_scene("res://MainMenu.tscn")
