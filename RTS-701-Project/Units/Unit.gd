extends Entity

class_name Unit

# Order List (A queue of assigned orders, holding shift should assign to the bottom)
var orders = [] # Array of lists where each entry contains the type and order information
enum {ORDER_NAVIGATION_POSITION, ORDER_NAVIGATION_NODE, ORDER_TYPE_ATTACK,}

# Current navigation information
#var target_node # Target Node (Should be typed but https://github.com/godotengine/godot/issues/21461)

var navmesh_id:int = 0
const NAVIGATION_RECALCULATION_FREQUENCY:float = 1.0 # Seconds
var navigation_recalculation_timer:Timer = null

var navigation_processed: bool = false
var initial_pos = Vector3() # initial position of the unit
var target_location:Vector3 = Vector3(0, 0, 0) # Target Location
var path = PoolVector3Array()
var SPEED = 4.00 # how fast we want to move the unit

var camera:Camera = null

# Action State and Effect
var action_countdown:float
var active_action:int

func _ready():
	# Add navigation node linked to the navigation mesh from the map
	camera = get_node("/root/Main/Affiliation/Player1/Camera") # send the correct player in the order
#	navigation = Navigation2D.new()
#	var navigation_mesh_instance:NavigationMeshInstance = get_node("root/Main/Game/Map/Navigation").get_child(0)

#	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
#	navigation_mesh_instance.set_enabled(true)
#	navigation.add_child(navigation_mesh_instance)
	pass

func _physics_process(delta: float) -> void:
	process_current_order(delta)

func process_current_order(delta:float) -> void:
	if orders.size() == 0:
		# Default behaviour without player added orders

		# Choose the closest target within a constant passive action radius

		# Add an order for that target

		return

	var order_type:int = get_order_type()
	if order_type == ORDER_NAVIGATION_POSITION or order_type == ORDER_NAVIGATION_NODE:
		# Process current navigation goal (recalculate at a frequency)
		process_navigation(delta)

		# If navigation is complete, pop it from the queue
		
		pass
	elif order_type == ORDER_TYPE_ATTACK:
		# Do navigation the same as above

		# Attack if within range

		# If target node is destroyed / gone, pop this order from the queue
		pass
	else:
		# Undefined order type
		pass
		
func process_navigation(delta:float) -> void:
	if not navigation_processed:
		initial_pos = get_translation()
		target_location = get_navigation_target_position()
		var nav = get_node('/root/Main/Game/Map/Navigation') 
		if nav:
			print('navigation found')
		path = nav.get_simple_path(
			initial_pos, 
			# do not let units pile up on eachother
			target_location+Vector3(randi()%100, randi()%100, randi()%100) 
		)
		
		navigation_processed = true
	if path.size() > 0:
		print('path size still there')
		move_unit(initial_pos, path[0], delta)
	else:
		navigation_processed = false

func get_z() -> float:
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var from:Vector3 = camera.project_ray_origin(mouse_position)
	var to:Vector3 = from + camera.project_ray_normal(mouse_position) * 1000
	return get_node('/root/Main/Game/Map/Navigation').get_closest_point_to_segment(from, to).z
	
#	var u:Vector3 = l2 - l1
#	var h:Vector3 = l1 - plane_co
#	var dot:float = plane_no.dot(u)

#	if abs(dot) > 0.0000001:
#		var lambda:float = - (plane_no.dot(h) / dot)
#		return l1 + u * lambda
#	else:
#		return Vector3(0, 0, 0)

func move_unit(from: Vector3, to: Vector3, delta:float):
	# get unit direction from one vector to the other
	var v = (to-from).normalized()
	v *= delta * SPEED # scale for how much to move
	var next_pos = initial_pos + v
	#if next_pos.distance_squared_to(from) < 3:
	path.remove(0)
	initial_pos = next_pos
	translation.x = initial_pos.x
	translation.y = initial_pos.y
	translation.z = get_z()
		
func get_navigation_target_position():
	var order_type:int = get_order_type()
	if order_type == ORDER_NAVIGATION_POSITION:
		return orders[0][1]
	elif order_type == ORDER_NAVIGATION_NODE:
		var node = orders[0][1] as Spatial
		return node.translation

func rpc_add_navigation_order_position(position:Vector3):
	add_navigation_order_position(position)
	rpc("add_navigation_order", position)

remote func add_navigation_order_position(position:Vector3):
	orders.push_back([ORDER_NAVIGATION_POSITION, position])
	
remote func add_navigation_order_node(node_path:String):
	orders.push_back([ORDER_NAVIGATION_NODE, node_path])

func rpc_clear_order_queue():
	clear_order_queue()
	rpc("clear_order_queue")

remote func clear_order_queue():
	orders.clear()
	
func get_order_type():
	if orders:
		return orders[0][0]
	else:
		return null


# =================================================================================================
# ============ Override methods for functionality specific to specific types of units =============
# =================================================================================================

func action_complete(type:int):
	pass