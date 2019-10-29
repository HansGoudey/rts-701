extends Building

func _ready():
	var mesh_file = load("res://Buildings/Basic.glb")
	add_child(mesh_file.instance())	
	
# Override functions from Building class

func initialize_health():
	maximum_health = 100
	health = maximum_health

func production_finish() -> void:
	pass