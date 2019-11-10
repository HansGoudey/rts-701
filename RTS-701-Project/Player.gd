extends Node

class_name Player
# TODO: Organize functions into sections

"""
A player corresponds to a human interacting with an affiliation. It will always
be the child of an 'Affiliation' node.
"""

# Name for UI (not the name of the node)
var id:String = ""

# Affiliation (should be the parent of this node)
var affiliation:Affiliation

# Lobby Information
var ready_to_start:bool = false
signal ready_to_start

# Mouse Event Handling
var mouse_down_left:bool = false
var mouse_drag:bool = false
var mouse_drag_time:float = 0
const DRAG_START_TIME:float = 0.2
const ENTITY_SELECTION_MAX_DISTANCE:float = 4.0

# Box Select State
var box_select_start:Vector3 = Vector3(0, 0, 0)
var box_select_end:Vector3 = Vector3(0, 0, 0)
var box_entities = []

# Selected Entities (group of 'Entity' nodes)
# TODO: Sync selected entities with players in the same affiliation so they know what you're doing
var selected_entities = [] # TODO: Maybe switch to using built in Godot groups

# Camera Node (should be child of this node)
var camera:Camera
var camera_velocity:Vector3 = Vector3(0, 0, 0)

# Creating a new building and unit
var create_building_mode:bool = false
var create_unit_mode:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")

	# Make this player's camera the active camera if it is the player for the local computer
	if self.is_network_master():
		camera.make_current()

# Load UI when game is started
func load_ui():
	var ui_scene = load("res://UI/GameUI.tscn")
	var game_ui:Control = ui_scene.instance()
	add_child(game_ui)
	assert(game_ui.connect("place_building_pressed", self, "place_building_pressed") == OK)
	assert(game_ui.connect("place_unit_pressed", self, "place_unit_pressed") == OK)

func place_building_pressed():
	create_building_mode = true
	create_unit_mode = false

func place_unit_pressed():
	create_unit_mode = true
	create_building_mode = false

func add_building():
	affiliation.rpc_add_building(affiliation.BUILDING_TYPE_BASIC, project_mouse_to_terrain_plane())
	create_building_mode = false

func add_unit():
	affiliation.rpc_add_unit(affiliation.UNIT_TYPE_BASIC, project_mouse_to_terrain_plane())
	create_unit_mode = false

remote func set_camera_translation(translation:Vector3):
	camera.translation = translation

func camera_movement(delta:float):
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
	# TODO: This means the smoothness depends on the framerate. The delta should be incorporated here
	camera_velocity *= 0.95

	camera.translation += camera_velocity
	rpc_unreliable("set_camera_translation", camera.translation)

func clear_selected_entities() -> void:
	for node in selected_entities:
		var entity:Entity = node as Entity
		entity.deselect()
	selected_entities.clear()

# Select the entity under the mouse cursor to the selection
func select_entity() -> void:
	print("Select Entity")
	# Linear search for the closest entity to the point projected on the terrain
	var selection_point:Vector3 = project_mouse_to_terrain_plane()
	var closest_distance:float = 9999999 # TODO: Figure out max float
	var closest_entity:Entity = null
	for child in affiliation.get_children():
		if child is Entity:
			var entity:Entity = child as Entity
			var distance_to_entity = entity.get_translation().distance_to(selection_point)
			if distance_to_entity < closest_distance:
				closest_distance = distance_to_entity
				closest_entity = entity

	# Check for no entities found and create selection
	if not closest_entity or closest_distance > ENTITY_SELECTION_MAX_DISTANCE:
		return
	closest_entity.select()
	if Input.is_key_pressed(KEY_SHIFT):
		selected_entities.append(closest_entity) # TODO: Does this concatonate arrays??
	else:
		clear_selected_entities()
		selected_entities = [closest_entity]

# Intersection of a line with a plane. Returns (0, 0, 0) if parallel.
# Logic from Blender source at:
# https://developer.blender.org/diffusion/B/browse/master/source/blender/blenlib/intern/math_geom.c$2181
static func isect_line_plane_v3(l1:Vector3, l2:Vector3, plane_co:Vector3, plane_no:Vector3) -> Vector3:
	var u:Vector3 = l2 - l1
	var h:Vector3 = l1 - plane_co
	var dot:float = plane_no.dot(u)

	if abs(dot) > 0.0000001:
		var lambda:float = - (plane_no.dot(h) / dot)
		return l1 + u * lambda
	else:
		return Vector3(0, 0, 0)

func project_mouse_to_terrain_plane() -> Vector3:
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var from:Vector3 = camera.project_ray_origin(mouse_position)
	var to:Vector3 = from + camera.project_ray_normal(mouse_position) * 1000

	var navigation_node:Navigation = get_node("/root/Main/Game/Map/Navigation")

	if navigation_node:
		return navigation_node.get_closest_point_to_segment(from, to)
	else:
		return isect_line_plane_v3(to, from, Vector3(0, 0, 0), Vector3(0, 1, 0))

func start_box_select() -> void:
	print("Start Box Select")
	# Raycast to the terrain plane (y = 0) to get the starting location
	box_select_start = project_mouse_to_terrain_plane()

# Select the entities inside the box drawn by a mouse drag
func handle_box_select() -> void:
	print("Handle Box Select")
	# Raycast to the terrain to get the second box select location
	box_select_end = project_mouse_to_terrain_plane()

	# Then find all of the entities within the box
	box_entities.clear() # Start building box_entities from scratch
	for child in affiliation.get_children():
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
			child.select()

func end_box_select() -> void:
	print("End Box Select")
	# Replace the selection or add it to the current selection depending on modifier keys
	if Input.is_key_pressed(KEY_SHIFT):
		selected_entities += box_entities # TODO: Does this concatonate arrays??
	else:
		clear_selected_entities()
		selected_entities = box_entities.duplicate()

	# We're done with the box select entities array now
	box_entities.clear()

func _process(delta):
	if self.is_network_master():
		camera_movement(delta)
		if mouse_down_left:
			mouse_drag_time += delta

			# Start box select routine if the mouse has dragged for long enough
			if mouse_drag_time > DRAG_START_TIME and not mouse_drag:
				mouse_drag = true
				start_box_select()
			if mouse_drag:
				handle_box_select() # Put this here so the selection updates when there are no mouse events

func _input(event:InputEvent):
	if self.is_network_master():
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed: # Mouse just pressed or has been pressed
					if create_building_mode:
						add_building()
					elif create_unit_mode:
						add_unit()
					else:
						mouse_down_left = true
						if mouse_drag:
							print("mouse_drag")
							handle_box_select()
				else: # Mouse just released
					mouse_down_left = false
					# If the mouse wasn't dragging and it was released, run select
					if mouse_drag:
						end_box_select()
					else:
						select_entity()
					mouse_drag = false
					mouse_drag_time = 0
			elif event.button_index == BUTTON_RIGHT:
				if selected_entities.size() > 0:
					for entity in selected_entities:
						if entity is Unit:
							var unit:Unit = entity as Unit
							unit.add_navigation_order()

func rpc_set_id(id:String) -> void:
	set_id(id)
	rpc("set_id", id)

remote func set_id(id:String) -> void:
	self.id = id

func rpc_set_lobby_ready(ready:bool) -> void:
	set_lobby_ready(ready)
	rpc("set_lobby_ready", ready)

remote func set_lobby_ready(ready:bool) -> void:
	self.ready_to_start = ready
	emit_signal("ready_to_start")
