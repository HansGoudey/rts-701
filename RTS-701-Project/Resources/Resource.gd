extends Spatial

class_name MapResource

var health:int

enum {RESOURCE0 = 0, RESOURCE1 = 1, RESOURCE2 = 2}

func load_resource(type:int) -> void:
	if type == RESOURCE0:
		pass
	elif type == RESOURCE1:
		pass
	elif type == RESOURCE2:
		pass

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