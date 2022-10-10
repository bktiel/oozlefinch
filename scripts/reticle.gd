extends CanvasLayer

# target to track
var target


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if(is_instance_valid(target)):
		$txtReticle.rect_position.x=target.global_position.x-$txtReticle.rect_size.x/2
		$txtReticle.rect_position.y=target.global_position.y-$txtReticle.rect_size.x/2
		
		
func hide():
	$txtReticle.hide()
	
func show():
	$txtReticle.show()
