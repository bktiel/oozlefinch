extends Area2D

export var speed = 350

signal intercepted()

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
	if(body.get_class()=="Missile"):
		if(body.dead):
			return
		if(body.pursuer==self):
			emit_signal("intercepted")			
			set_physics_process(false)
			hide()
			body._on_Missile_body_entered(self)
	elif(body.get_class()=="Hind"):
		if(body.dead):
			return
		if(body.pursuer==self):
			emit_signal("intercepted")
			set_physics_process(false)
			hide()
			body.destroyed_by(self)
	
func get_class():
	return "PatriotMissile"
