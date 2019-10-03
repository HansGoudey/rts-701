extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load UI
	var ui_scene = load("res://MenuUI.tscn")
	var ui_node = ui_scene.instance()
	add_child(ui_node)
	ui_node.connect("start_game", self, "start_game")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_game():
	# Load game scene
	var game_scene = load("res://Game.tscn")
	var game_node = game_scene.instance()
	add_child(game_node)