extends Spatial

func _ready():
	# Load map
	var map_scene = preload("res://Map/Map.tscn")
	add_child(map_scene.instance())

func start_game():
	pass

func place_start_map_items():
	$Map.place_map_items()