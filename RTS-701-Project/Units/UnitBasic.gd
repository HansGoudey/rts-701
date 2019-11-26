extends Unit

func _ready():
	damage_type_multipliers = [1, 1, 1]

func _process(delta):
	pass


# =================================================================================================
# ============================= Functions overriden from Entity Class =============================
# =================================================================================================

func initialize_health() -> void:
	maximum_health = 100
	health = maximum_health

func set_cost():
# warning-ignore:unused_variable
	for i in range(affiliation.resources.size()):
		cost.append(10)

func die() -> void:
	pass


# =================================================================================================
# ============================== Functions overriden from Unit Class ==============================
# =================================================================================================

func action_complete(type:int):
	pass

func set_speed():
	self.speed = 4.0

func set_action_range():
	self.action_range = 4.0
