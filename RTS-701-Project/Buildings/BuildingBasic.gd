extends Building

func _ready():
	var mesh_file = load("res://Buildings/Basic.glb")
	add_child(mesh_file.instance())	
	
# Override Functions rom Building class

func production_finish() -> void:
	pass

# Override Functions from Entity Class

func set_cost() -> void:
	# TODO: Use global for entire game to define the number of resources
	for i in range(affiliation.resources.size()):
		cost[i] = 10

func initialize_health():
	maximum_health = 100
	health = maximum_health
	