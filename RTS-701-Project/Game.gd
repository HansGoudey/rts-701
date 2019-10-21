extends Spatial

# Affiliations
var n_affiliations: int = 0
var affiliations = []

func _ready():
	# Load map
	var map_scene = load("res://Map/Map.tscn")
	add_child(map_scene.instance())
