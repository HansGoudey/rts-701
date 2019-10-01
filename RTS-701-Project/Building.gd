extends Entity

class_name Building

# Production State (Countdown or position in production process)
var production_selection: int = 0
var production_countdown: float = 0
var production_active: bool = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if production_countdown > 0:
		production_countdown -= delta
