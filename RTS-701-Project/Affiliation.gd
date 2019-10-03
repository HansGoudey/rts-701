extends Node

class_name Affilation

# ID / Color

# Resource Counts

# Linked Player Nodes

# Entities Owned by Affiliation

# Visible Area (Fog of war)

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_scene = load("res://Player.tscn")
	var player_node = player_scene.instance()
	add_child(player_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
