extends Spatial

class_name MapResource

var health:int = 100
var resource_type:int

enum {RESOURCE0 = 0, RESOURCE1 = 1, RESOURCE2 = 2}

func _ready():
	add_to_group("targets")

func get_class(): 
	return "MapResource"

func load_resource(type:int) -> void:
	var resource_scene
	if type == RESOURCE0:
		resource_scene = load("res://Resources/1.glb")
	elif type == RESOURCE1:
		resource_scene = load("res://Resources/2.glb")
	elif type == RESOURCE2:
		resource_scene = load("res://Resources/3.glb")
	var resource_mesh = resource_scene.instance()
	add_child(resource_mesh)
	self.resource_type = type

# Returns an amount harvested from the resource
func harvest(damage:int) -> int:
	if health > damage:
		health -= damage
		return damage
	else:
		die()
		return health

func die() -> void:
	self.queue_free()