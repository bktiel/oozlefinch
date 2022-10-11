extends Area2D

export var speed = 350

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func start(_transform):
	global_transform = _transform
	velocity = transform.x * speed
	scale=Vector2(0.3,0.3)

func _physics_process(delta):
	# expand boolet
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta
	
	scale.x=clamp(scale.x+0.01,0.3,1)
	scale.y=clamp(scale.y+0.01,0.3,1)
	



func _on_Lifetime_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	if(body.get_class()=="Player"):
		body.shock()
	queue_free()
