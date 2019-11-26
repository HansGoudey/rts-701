extends Unit

func _ready():
	self.damage_type_multipliers = [1, 1, 1]

func _process(delta):
	pass


# =================================================================================================
# ============================= Functions overriden from Entity Class =============================
# =================================================================================================

func initialize_health() -> void:
	self.maximum_health = 100
	self.health = self.maximum_health

func set_cost():
# warning-ignore:unused_variable
	for i in range(self.affiliation.resources.size()):
		self.cost.append(10)

func die() -> void:
	pass


# =================================================================================================
# ============================== Functions overriden from Unit Class ==============================
# =================================================================================================

func action_complete(type:int):
	pass

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0
