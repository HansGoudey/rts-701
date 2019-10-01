extends Entity

class_name Unit

# Order List (A stack of assigned orders, holding shift should assign to the bottom)
var orders

# Action State and Effect
var action_countdown: float
var active_action: int

# Action Effect (Should refer to an 'action_complete' function from a type child)

# Target Node (If the action applies to a node)
var target_node # Should be typed but https://github.com/godotengine/godot/issues/21461

# Target Location (If the action applies to a location)
var target_location: Vector3 = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
