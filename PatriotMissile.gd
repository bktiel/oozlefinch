extends Area2D

export var speed = 350

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target

func start(_transform,_target):
	if(!is_instance_valid(_target)):
		queue_free()
		return
	else:
		target=_target
	# inform target tracking
	if(!is_instance_valid(target)):
		queue_free()
		return
	else:
		target.pursuer=self
	global_transform = _transform
	velocity = transform.x * speed

func _physics_process(delta):
	if(!is_instance_valid(target) or target.dead):
		queue_free()	
		return
	else:
		look_at(target.position)
	# shrink over time
	scale.x=clamp(scale.x-0.01,0.5,1)
	scale.y=clamp(scale.y-0.01,0.5,1)
	
	velocity=Vector2(300,0).rotated(rotation)
	position += velocity * delta


func _on_Lifetime_timeout():
	queue_free()


func _on_PatriotMissile_body_entered(body):
	if(body.dead):
		return
	if(body.get_class()=="Missile" and body.pursuer==self):
		set_physics_process(false)
		hide()
		body._on_Missile_body_entered(self)
	
func get_class():
	return "PatriotMissile"
