extends Entity

class_name Unit

# Debugging variables
var debug_draw_navigation_path:bool = true
var debug_im:ImmediateGeometry = null
var debug_im_material:SpatialMaterial = null

# Unit information set from unit type
var speed:float = 0.0 # Speed of unit (Meters / Second)
var action_range:float = 0.0 # Range of actions (Meters)

# Order List (A queue of assigned orders, holding shift should assign to the bottom)
var orders = [] # Array of lists where each entry contains the type and order information
enum {ORDER_NAVIGATION_POSITION, ORDER_NAVIGATION_NODE, ORDER_ATTACK,}

# Current navigation information
var navigation:Navigation2D = null
var navigation_terrain_3d:Navigation = null
var target_node # Target Node (Should be typed but https://github.com/godotengine/godot/issues/21461)
var navigation_recalculation_timer:Timer = null
var path:PoolVector2Array = PoolVector2Array()

const NAVIGATION_RECALCULATION_FREQUENCY:float = 4.0 # Seconds
const NAVIGATION_POINT_REACHED_DISTANCE:float = 0.1 # Distance to the current point along the path before switching to the next

# Action State and Effect
var action_countdown:float
var active_action:int

func _ready():
	# Set up navigation variables
	navigation_terrain_3d = get_node('/root/Main/Game/Map/Navigation') # 3D for terrain intersection
	navigation = get_node('/root/Main/Game/Map/Navigation2D') # 2D for unit pathfinding
	navigation_recalculation_timer = Timer.new()
	add_child(navigation_recalculation_timer)
	if debug_draw_navigation_path:
		debug_im = ImmediateGeometry.new()
		debug_im_material = SpatialMaterial.new()
		debug_im_material.flags_unshaded = true
		debug_im_material.flags_use_point_size = true
		debug_im_material.albedo_color = Color(1.0, 0.5, 0.9, 1.0)
		get_node("/root/Main/Game/Map").add_child(debug_im)

	# Set specific information from unit type
	set_speed()
	set_action_range()

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
		# If navigation is complete, pop it from the queue
		if navigation_complete():
			pop_order()

		# Process current navigation goal (recalculate at a frequency)
		process_navigation(delta)
	elif order_type == ORDER_ATTACK:
		# If target node is destroyed / gone, pop this order from the queue
		var target_node:Spatial = get_navigation_target_node()
		if not target_node:
			pop_order()

		# Attack if within range, if out of range process the navigation
		if self.translation.distance_to(get_navigation_target_position()) < action_range:
			pass
		else:
			process_navigation(delta)
	else:
		# Undefined order type
		print("Undefined order type")

func navigation_complete() -> bool:
	return self.translation.distance_to(get_navigation_target_position()) < NAVIGATION_POINT_REACHED_DISTANCE

func navigation_clear() -> void:
	path.resize(0)

func calculate_navigation_path(target_location:Vector3) -> void:
	print("Calculate Navigation Path")
	print("  Target Location: (", target_location.x, ", ", target_location.z, ")")
	# Get the path from the map's 2D analog
	var from:Vector2 = navigation.get_closest_point(get_2d_translation())
	var target_location_2d:Vector2 = Vector2(target_location.x, target_location.z)
	# Add a random offset to the target location so units don't pile up
#	var target_2d:Vector2 = navigation.get_closest_point(target_location_2d + Vector2(randi() % 100, randi() % 100))
	var to:Vector2 = navigation.get_closest_point(target_location_2d)
	print("  From: (", from.x, ", ", from.y, ")")
	print("  To: (", to.x, ", ", to.y, ")")
	path = navigation.get_simple_path(from, to)
	# TODO: Check for error in navigation calculation

	# Start the navigation recalculation timer
	navigation_recalculation_timer.start(NAVIGATION_RECALCULATION_FREQUENCY)

	if debug_draw_navigation_path:
		debug_im.clear()
		debug_im.set_material_override(debug_im_material)
		debug_im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		for i in range(path.size()):
			debug_im.add_vertex(Vector3(path[i].x, get_terrain_height(path[i].x, path[i].y) + 1, path[i].y))
		debug_im.end()

		var path_string:String = "["
		for i in range(path.size()):
			if i != 0:
				path_string += ", "
			path_string += "(" + str(path[i].x) + ", " + str(get_terrain_height(path[i].x, path[i].y)) + ", " + str(path[i].y) + ")"
		path_string += "]"
		print(path_string)

func process_navigation(delta:float) -> void:
#	print("Process Navigation")
	# Recalculate navigation on a timer or if the path is empty
	if path.size() == 0 or navigation_recalculation_timer.time_left == 0:
		calculate_navigation_path(get_navigation_target_position())
		navigation_recalculation_timer.start(NAVIGATION_RECALCULATION_FREQUENCY)

	# If we reached the next navigation point, start moving to the one after
	if self.get_2d_translation().distance_to(path[0]) < NAVIGATION_POINT_REACHED_DISTANCE:
		path.remove(0)
		if path.size() == 0:
			pop_order()
			return

	# Move toward the next navigation point
	# TODO: Maybe add smooth movement by changing the velocity?
	var next_point:Vector2 = path[0]
	var next_point_3d:Vector3 = Vector3(next_point.x, self.translation.y, next_point.y)
	var next_point_direction:Vector3 = self.translation.direction_to(next_point_3d)
	self.translation += next_point_direction * speed * delta
	self.translation.y = get_terrain_height(self.translation.x, self.translation.z) + 0.5

func get_terrain_height(x:float, z:float) -> float:
	# TODO: Assert that the x, z position is within the bounds of the terrain
	var down:Vector3 = Vector3(x, -100, z)
	var up:Vector3 = Vector3(x, 100, z)
	return navigation_terrain_3d.get_closest_point_to_segment(down, up).y

func get_navigation_target_position():
	var order_type:int = get_order_type()
	if order_type == ORDER_NAVIGATION_POSITION:
		return orders[0][1]
	elif order_type == ORDER_NAVIGATION_NODE or order_type == ORDER_ATTACK:
		var node = orders[0][1] as Spatial
		return node.translation

func get_navigation_target_node():
	var order_type:int = get_order_type()
	assert(order_type == ORDER_NAVIGATION_NODE or order_type == ORDER_ATTACK)
	var node = orders[0][1]
	return node

func get_order_type() -> int:
	if orders:
		return orders[0][0]
	else:
		return -1

func get_2d_translation() -> Vector2:
	return Vector2(self.translation.x, self.translation.z)

func rpc_pop_order() -> void:
	pop_order()
	rpc("pop_order")

func pop_order() -> void:
	orders.pop_front()

func rpc_add_navigation_order_position(position:Vector3) -> void:
	add_navigation_order_position(position)
	rpc("add_navigation_order", position)

remote func add_navigation_order_position(position:Vector3) -> void:
	orders.push_back([ORDER_NAVIGATION_POSITION, position])

remote func add_navigation_order_node(node_path:String) -> void:
	orders.push_back([ORDER_NAVIGATION_NODE, node_path])

func rpc_clear_orders() -> void:
	clear_orders()
	rpc("clear_order_queue")

remote func clear_orders() -> void:
	orders.clear()
	navigation_clear()


# =================================================================================================
# ============ Override methods for functionality specific to specific types of units =============
# =================================================================================================

func action_complete(type:int):
	pass

func set_speed():
	pass

func set_action_range():
	pass