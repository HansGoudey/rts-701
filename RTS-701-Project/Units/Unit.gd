extends Entity

class_name Unit

# Order List (A stack of assigned orders, holding shift should assign to the bottom)
var orders

# Action State and Effect
var action_countdown:float
var active_action:int

# Action Effect (Should refer to an 'action_complete' function from a type child)

# Target Node (If the action applies to a node)
var target_node # Should be typed but https://github.com/godotengine/godot/issues/21461

# Target Location (If the action applies to a location)
var target_location:Vector3 = Vector3(0, 0, 0)

func _ready():
	pass

#func _process(delta):
#	pass

func set_cost():
	# TODO: Use global for entire game to define the number of resources
	for i in range(affiliation.resources.size()):
		cost[i] = 10

remote func add_navigation_order():
	pass