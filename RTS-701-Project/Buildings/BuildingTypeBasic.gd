extends Node

var parent: Building = null

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	
	var mesh_file = load("res://Buildings/Basic.glb")
	add_child(mesh_file.instance())
	
func initialize_health():
	parent.health = 100
	parent.maximum_health = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
