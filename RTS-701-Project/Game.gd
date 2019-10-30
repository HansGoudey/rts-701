extends Spatial

# Affiliations
var affiliations = []

func _ready():
	# Load map
	var map_scene = preload("res://Map/Map.tscn")
	add_child(map_scene.instance())

	# Load UI and connect its signals to the local player
	var ui_scene = preload("res://UI/GameUI.tscn")
	var ui_node:Control = ui_scene.instance()
	add_child(ui_node)
	assert(ui_node.connect("place_building", self, "place_entity_down") == OK)
	assert(ui_node.connect("place_entity", self, "place_entity_down") == OK)

func start_game():
	# Affilations were passed into the member variable, add them as children
	var main:Main = get_parent()
	for affiliation in affiliations:
		main.remove_child(affiliation)
		add_child(affiliation)
