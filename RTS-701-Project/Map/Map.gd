extends Spatial

func _ready():
	# Add the terrain
	var terrain_file = preload("res://Map/SimpleTerrain.glb")
	add_child(terrain_file.instance())
	
