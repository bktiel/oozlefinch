extends KinematicBody2D

export var speed=400

# must be defined here for re-use
var velocity= Vector2.ZERO
var goal_x=Vector2.ZERO
var firing=false
var last_side=0
var screen_size

signal launcher_reached(launcher)

# Called when the node enters the scene tree for the first time.
func _ready():
	goal_x=position.x
	$CollisionShape2D.disabled = false
	screen_size=get_viewport_rect().size
		
	
func _process(delta):
	if velocity.x < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
func _physics_process(delta):
		# if not at goal, get there
	if position.x<goal_x:
		velocity.x +=1
	elif position.x>goal_x:
		velocity.x-=1
	
	#print(velocity)
	
	velocity=move_and_slide(velocity,Vector2(0,-1))
	for i in get_slide_count():
		_handle_collide(get_slide_collision(i))
# helper function for start in new_game
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# if touched, reset goal
func _handle_collide(collision):
	#print(collision.collider.name)
	if collision.collider.get_class()=="Patriot":
		goal_x=position.x # Replace with function body.
		if(firing):
			emit_signal("launcher_reached",collision.collider)
