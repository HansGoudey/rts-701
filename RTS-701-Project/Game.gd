extends Spatial

# Affiliations
var affiliations = []

func _ready():
	# Load map
	var map_scene = preload("res://Map/Map.tscn")
	add_child(map_scene.instance())

func start_game():
	# Affilations were passed into the member variable, add them as children
	var main:Main = get_parent()
	for affiliation in affiliations:
		main.remove_child(affiliation)
		add_child(affiliation)
