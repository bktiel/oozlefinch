extends StaticBody2D

var health=5
signal city_damaged
signal city_destroyed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	health=5

func damage_city():
	health-=1
	emit_signal("city_damaged")
	if(health<1):
		$City1Explosion.show()
		$City1Sprite.play("destroyed")
		$City1Explosion.play("explosion")
	

func get_class(): return "City"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_City1Explosion_animation_finished():
	emit_signal("city_destroyed")
