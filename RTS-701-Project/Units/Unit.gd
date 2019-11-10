extends Entity

class_name Unit

# Order List (A queue of assigned orders, holding shift should assign to the bottom)
var orders = [] # Array of list where each ty
enum {ORDER_TYPE_NAVIGATION, ORDER_TYPE_ATTACK,}

# Current navigation information
var target_node # Target Node (Should be typed but https://github.com/godotengine/godot/issues/21461)
var target_location:Vector3 = Vector3(0, 0, 0) # Target Location
var navigation:Navigation = null
var navmesh_id:int = 0
const NAVIGATION_RECALCULATION_FREQUENCY:float = 1.0 # Seconds

# Action State and Effect
var action_countdown:float
var active_action:int

func _ready():
	# Add navigation node linked to the navigation mesh from the map
#	navigation = Navigation.new()
#	var navigation_mesh_instance:NavigationMeshInstance = get_node("root/Main/Game/Map/Navigation").get_child(0)

#	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
#	navigation_mesh_instance.set_enabled(true)
#	navigation.add_child(navigation_mesh_instance)
	pass

func _process(delta):
	process_current_order()

func process_current_order():
	if orders.size() == 0:
		return

	var order_type:int = orders[0][0]
	if order_type == ORDER_TYPE_NAVIGATION:
		# Process current navigation goal (recalculate at a frequency)

		# If navigation is complete, pop it from the stack
		pass
	elif order_type == ORDER_TYPE_ATTACK:
		# Do navigation the same as above

		# Attack if within range
		pass
	else:
		# Undefined order type
		pass

remote func add_navigation_order(position:Vector3):
	orders.push_back([ORDER_TYPE_NAVIGATION, position])

# =================================================================================================
# ============ Override methods for functionality specific to specific types of units =============
# =================================================================================================

func action_complete(type:int):
	pass