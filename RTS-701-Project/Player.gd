extends Node

class_name Player

"""
A player corresponds to a human interacting with an affiliation. It will always
be the child of an 'Affiliation' node.
"""

# Name for UI (not the name of the node)
var id:String = ""

# Affiliation (should be the parent of this node)
var affiliation:Affiliation = null

# Lobby Information
var ready_to_start:bool = false
signal ready_to_start

# Mouse Event Handling
var mouse_down_left:bool = false
var mouse_drag:bool = false
var mouse_drag_time:float = 0
const DRAG_START_TIME:float = 0.2

# Box Select State
var box_select_start:Vector3 = Vector3(0, 0, 0)
var box_select_end:Vector3 = Vector3(0, 0, 0)
var box_entities = []

# Selected Entities (group of 'Entity' nodes)
var selected_entities = []

# Camera Node (should be child of this node)
var camera:Camera
var camera_velocity:Vector3 = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")
	
func camera_movement(delta):
	var camera_acceleration: float = 1
	if Input.is_action_pressed("camera_right"):
		camera_velocity.x += delta * camera_acceleration
	if Input.is_action_pressed("camera_left"):
		camera_velocity.x -= delta * camera_acceleration
	if Input.is_action_pressed("camera_forward"):
		camera_velocity.z -= delta * camera_acceleration
	if Input.is_action_pressed("camera_backward"):
		camera_velocity.z += delta * camera_acceleration
	if Input.is_action_pressed("camera_up"):
		camera_velocity.y += delta * camera_acceleration
	if Input.is_action_pressed("camera_down"):
		camera_velocity.y -= delta * camera_acceleration
	
	# Smoothly lower the camera velocity
	camera_velocity *= 0.95

	camera.translate(camera_velocity)
	rset_unreliable("camera.translation", camera.translation)

func set_lobby_ready(ready:bool) -> void:
	self.ready_to_start = ready
	emit_signal("ready_to_start")

# Select the entity under the mouse cursor to the selection
func select_entity(event: InputEvent):
	pass

# Intersection of a line with a plane. Returns (0, 0, 0) if parallel.
# Logic from Blender source at:
# https://developer.blender.org/diffusion/B/browse/master/source/blender/blenlib/intern/math_geom.c$2181
static func isect_line_plane_v3(l1: Vector3, l2: Vector3, plane_co: Vector3, plane_no: Vector3) -> Vector3:
	var u: Vector3 = l2 - l1
	var h: Vector3 = l1 - plane_co
	var dot: float = plane_no.dot(u)
	
	if abs(dot) > 0.0000001:
		var lambda: float = - (plane_no.dot(h) / dot)
		return l1 + u * lambda
	else:
		return Vector3(0, 0, 0)

func project_mouse_to_terrain_plane() -> Vector3:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position)
	
	return isect_line_plane_v3(to, from, Vector3(0, 0, 0), Vector3(0, 1, 0))

func start_box_select():
	# Raycast to the terrain plane (y = 0) to get the starting location
	box_select_start = project_mouse_to_terrain_plane()

# Select the entities inside the box drawn by a mouse drag
func handle_box_select():
	# Raycast to the terrain to get the second box select location
	box_select_end = project_mouse_to_terrain_plane()
	
	# Then find all of the entities within the box
	var parent_affiliation: Affiliation = get_parent()
	for child in parent_affiliation.get_children():
		if child is Entity:
			# Figure out it the entity is in the box, accounting for a the box end being larger or smaller than the start
			if box_select_start.x < box_select_end.x:
				if not (child.translation.x > box_select_start.x and child.translation.x < box_select_end.x):
					continue
			else:
				if not (child.translation.x < box_select_start.x and child.translation.x > box_select_end.x):
					continue
			if box_select_start.y < box_select_end.y:
				if not (child.translation.y > box_select_start.y and child.translation.y < box_select_end.y):
					continue
			else:
				if not (child.translation.y < box_select_start.y and child.translation.y > box_select_end.y):
					continue
			
			# If we're still in this iteration the entity is in the box, so append it
			box_entities.append(child)
	
func end_box_select():
	# Replace the selection or add it to the current selection depending on modifier keys
	if Input.is_key_pressed(KEY_SHIFT):
		selected_entities += box_entities # TODO: Does this concatonate arrays??
	else:
		selected_entities = box_entities.duplicate()
	
	# We're done with the box select entities array now
	box_entities.clear()

func _process(delta):
	if self.is_network_master():
		camera_movement(delta)
		if mouse_down_left:
			mouse_drag_time += delta
		if mouse_drag:
			handle_box_select() # Put this here so the selection updates when there are no mouse events

func _unhandled_input(event: InputEvent):
	if self.is_network_master():
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					# Mouse just pressed or has been pressed
					mouse_down_left = true
					if mouse_drag:
						pass
					elif mouse_drag_time > DRAG_START_TIME:
						# Start mouse drag after holding it down for enough time
						mouse_drag = true
						start_box_select()
				else:
					# Mouse just released
					mouse_down_left = false
					# If the mouse wasn't dragging and it was released, run select
					if mouse_drag:
						end_box_select()
					else:
						select_entity(event)
					mouse_drag = false
					mouse_drag_time = 0
