extends Spatial

class_name MapResource

var health:int
var type: int

enum {RESOURCE0 = 0, RESOURCE1 = 1, RESOURCE2 = 2}

func load_resource(type:int) -> void:
	if type == RESOURCE0:
		self.type = 0
	elif type == RESOURCE1:
		self.type = 1
	elif type == RESOURCE2:
		self.type = 2

# Returns an amount harvested from the resource
func harvest(damage:int) -> int:
	if health > damage:
		health -= damage
		return damage
	else:
		return health

func is_dead():
	return health > 0

func die() -> void:
	self.queue_free()