extends Building

func _ready():
	type = Affiliation.BUILDING_TYPE_ARMY
	maximum_health = 100
	health = maximum_health
	damage_type_multipliers = [1, 1, 1]

func _process(delta):
	pass


# =================================================================================================
# ============================= Functions overriden from Entity Class =============================
# =================================================================================================

func initialize_health() -> void:
	maximum_health = 100
	health = maximum_health

func set_cost() -> void:
# warning-ignore:unused_variable
	for i in range(affiliation.resources.size()):
		cost.append(10)

func die() -> void:
	pass


# =================================================================================================
# ============================ Functions overriden from Building Class ============================
# =================================================================================================

func production_finish() -> void:
	var new_unit:Unit = affiliation.rpc_add_unit(Affiliation.UNIT_TYPE_ARMY, self.translation)
	new_unit.rpc_add_navigation_order_position(self.translation + Vector3(0, 0, 2))
	self.production_timer.stop()

