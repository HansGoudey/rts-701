extends Node

class_name Player

"""
A player corresponds to a human interacting with an affiliation. Because of this it will always
be the child of an 'Affilation' node.
"""

# Selected Entities (group of 'Entity' nodes)
var box_select_mode: bool = false
var box_select_start: Vector3 = Vector3(0, 0, 0)
var box_select_end: Vector3 = Vector3(0, 0, 0)


# Camera Node (should be child of this node)
var camera: Camera
var camera_velocity: Vector3 = Vector3(0, 0, 0)

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
	
	# Smoothly lower the camera velocity while nothing is pressed
	camera_velocity *= 0.95

	camera.translation += camera_velocity
	
# Select the entity under the mouse cursor to the selection
func select_entity():
	pass

# Select the entities inside the box drawn by a mouse drag
func handle_box_select():
	pass

func _process(delta):
	camera_movement(delta)
	handle_box_select()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# Start box select if it isn't running
			if event.pressed and not box_select_mode:
				box_select_mode = true
			# End box select if it's running and the mouse is released
			elif not event.pressed and box_select_mode:
				box_select_mode = false
			
			# Wait a certain amount of time and if the mouse isn't still down than it wasn't a box
			# select, it was a just a regular select
