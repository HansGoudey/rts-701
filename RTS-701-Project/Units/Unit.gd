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

# Current navigation information
#var navigation:Navigation = null
#var navmesh_id:int = 0

func _ready():
	# Add navigation node linked to the navigation mesh from the map
#	navigation = Navigation.new()
#	var navigation_mesh_instance:NavigationMeshInstance = get_node("root/Main/Game/Map/Navigation").get_child(0)

#	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
#	navigation_mesh_instance.set_enabled(true)
#	navigation.add_child(navigation_mesh_instance)
	pass

func _process(delta):
	pass

remote func add_navigation_order():
	pass

# =================================================================================================
# ============ Override methods for functionality specific to specific types of units =============
# =================================================================================================

func action_complete(type:int):
	pass