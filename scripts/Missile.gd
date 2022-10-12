extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var id 
var dead
var pursuer
var questionIndex
signal clicked(target)
signal explode(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	id= get_instance_id()
	dead=false
	$AnimatedSprite.play("fly")
	
	
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	var direction=self.linear_velocity.angle()
	if dead:
		linear_velocity=Vector2.ZERO
		$AnimatedSprite.rotation=0
		self.rotation=0
	else:
		pass
		#linear_velocity = Vector2(rand_range(15,20), 0.0).rotated(direction)
	




func _on_Missile_body_entered(body):
	dead=true
	$labelHolder.hide()
	# if homing, remove
	if(is_instance_valid(pursuer)):
		pursuer.queue_free()
	$AnimatedSprite.scale= Vector2(0.8,0.8)
	self.set_deferred("mode","MODE_CHARACTER")
	self.set_deferred("rotation", 0)
	emit_signal("explode",self)
	$AnimatedSprite.play("explode") # Replace with function body.
	if body.get_class()=="City":
		body.damage_city()


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation=="explode":
		queue_free()


func _on_Missile_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and !dead:
		emit_signal("clicked",id)
		
func get_class():
	return "Missile"
