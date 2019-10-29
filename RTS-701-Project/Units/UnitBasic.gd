extends Unit

func _ready():
	maximum_health = 100
	health = maximum_health
	damage_type_multipliers = [1, 1, 1]

#func _process(delta):
#	pass

# Override Functions from Unit Class
	
func action_complete(type:int):
	pass

# Override Functions from Entity Class

func initialize_health() -> void:
	maximum_health = 100
	health = maximum_health
	
func set_cost() -> void:
	pass

	
func die() -> void:
	pass