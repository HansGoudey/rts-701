extends Spatial

# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	var terrain_file = load("res://Map/Terrain.glb")
	add_child(terrain_file.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
