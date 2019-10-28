extends Node

class_name Affiliation

# ID / Color
var id:String = ""
var color:Color = Color(0.0, 0.0, 0.0, 1.0)

# Resource Counts
var resource_1:float = 0
var resource_2:float = 0
var resource_3:float = 0
var resource_4:float = 0

# Linked Player Nodes
var players = []

# Visible Area (Fog of war)

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_scene = load("res://Player.tscn")
	var player_node = player_scene.instance()
	add_child(player_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_color_from_hue(hue:float) -> void:
	var color:Color = Color.from_hsv(hue, 0.75, 1)
	set_color(color)

remote func set_color(color:Color) -> void:
	self.color = color

sync func set_id(id:String) -> void:
	self.id = id
