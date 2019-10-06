extends Node

class_name Player

"""
A player corresponds to a human interacting with an affiliation. Because of this it will always
be the child of an 'Affilation' node.
"""

# Selected Entities (group of 'Entity' nodes)

# Camera Node (should be child of this node)
var camera: Camera
var camera_velocity: Vector3 = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")

func _process(delta):
	var camera_acceleration = 10
	if Input.is_action_pressed("camera_right"):
		camera_velocity.x += delta * camera_acceleration
	if Input.is_action_pressed("camera_left"):
		camera_velocity.x -= delta * camera_acceleration
	if Input.is_action_pressed("camera_forward"):
		camera_velocity.z += delta * camera_acceleration
	if Input.is_action_pressed("camera_backward"):
		camera_velocity.z -= delta * camera_acceleration
	if Input.is_action_pressed("camera_up"):
		camera_velocity.y += delta * camera_acceleration
	if Input.is_action_pressed("camera_down"):
		camera_velocity.y -= delta * camera_acceleration
	
	# Smoothly lower the camera velocity while nothing is pressed
	camera_velocity.x *= 0.9
	camera_velocity.y *= 0.9
	camera_velocity.z *= 0.9
	
	camera.translation.x += camera_velocity.x
	camera.translation.y += camera_velocity.y
	camera.translation.z += camera_velocity.z
	
