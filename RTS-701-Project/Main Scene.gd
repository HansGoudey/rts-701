extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load UI
	var ui_scene = load("res://MenuUI.tscn")
	var ui_node = ui_scene.instance()
	add_child(ui_node)
	ui_node.connect("start_game", self, "start_game")
	ui_node.connect("host_game", self, "host_game")
	ui_node.connect("join_game", self, "join_game")

sync func start_game():
	# Load game scene
	var game_scene = load("res://Game.tscn")
	var game_node = game_scene.instance()
	add_child(game_node)
	get_node("/root/Main/MenuUI").queue_free()

func host_game():
	pass

func join_game():
	pass