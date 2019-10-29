extends Spatial

# Affiliations
var affiliations = []

func _ready():
	# Load map
	var map_scene = preload("res://Map/Map.tscn")
	add_child(map_scene.instance())
	
func start_game():
	# Affilations were passed into the member variable, add them as children
	for affiliation in affiliations:
		add_child(affiliation)
