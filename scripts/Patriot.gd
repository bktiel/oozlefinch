extends StaticBody2D

# options
enum LAUNCHER_ORIENTATION {left,right}
export (LAUNCHER_ORIENTATION) var direction = LAUNCHER_ORIENTATION.left

export(PackedScene) var projectile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if(direction==LAUNCHER_ORIENTATION.right):
		$AnimatedSprite.play("right")
	else:
		$AnimatedSprite.play("left")

func fire(target):
	var missile=projectile.instance()
	add_child(missile)
	
	if(direction==LAUNCHER_ORIENTATION.left):
		missile.start($LaunchPointLeft.get_global_transform(),target)
	else:
		missile.start($LaunchPointRight.get_global_transform(),target)
		

func get_class(): return "Patriot"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
