extends StaticBody2D

# options
enum LAUNCHER_ORIENTATION {left,right}
export (LAUNCHER_ORIENTATION) var direction = LAUNCHER_ORIENTATION.left

export(PackedScene) var projectile

signal fire_missile(launcher)

# Called when the node enters the scene tree for the first time.
func _ready():
	if(direction==LAUNCHER_ORIENTATION.right):
		$AnimatedSprite.play("right")
	else:
		$AnimatedSprite.play("left")

func fire(target):
	emit_signal("fire_missile",self)
		

func get_class(): return "Patriot"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
