extends KinematicBody2D

export var speed=100

var goal_x=0
var _tolerance=4
var dead
var id
var questionIndex
var pursuer=null
var shoot_cooldown=0
var _cooldown=10
var shooting=false
var begin_shoot=0
var shots=0
var velocity= Vector2.ZERO
signal clicked(target)
signal reached_goal(target)
signal explode(target)
signal shoot(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	id= get_instance_id()
	dead=false

func _process(delta):
	if(shooting and shots>0 and shoot_cooldown>_cooldown and begin_shoot==0):
		shoot_cooldown=0
		emit_signal("shoot",self)
		shots-=1
	else:
		shoot_cooldown+=1
		begin_shoot-=1
	if velocity.x < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

func _physics_process(delta):
	randomize()

	if(dead):
		return
		# if not at goal, get there
	if abs(position.x-goal_x)<4:
		emit_signal("reached_goal",self)
		velocity=Vector2.ZERO
		return
	elif position.x<goal_x:
		velocity.x +=1
	elif position.x>goal_x:
		velocity.x-=1
		
	velocity=move_and_slide(velocity,Vector2(0,-1))

func strafe():
	pass

# blown up
func destroyed_by(other):
	dead=true
	$labelHolder.hide()
	# if homing, remove
	if(is_instance_valid(pursuer)):
		pursuer.queue_free()
	$AnimatedSprite.scale= Vector2(0.5,0.5)
	self.set_deferred("mode","MODE_CHARACTER")
	self.set_deferred("rotation", 0)
	emit_signal("explode",self)
	$AnimatedSprite.play("explode") 

func get_class():
	return "Hind"


func _on_Hind_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and !dead:
		emit_signal("clicked",id)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation=="explode":
		queue_free()
