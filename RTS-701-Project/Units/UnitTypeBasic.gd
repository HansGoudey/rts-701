extends Unit

func _ready():
	maximum_health = 100
	health = maximum_health
	damage_type_multipliers = [1, 1, 1]
	
func action_complete(type: int):
	pass

#func _process(delta):
#	pass
