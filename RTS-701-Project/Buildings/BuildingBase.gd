extends Building

func _ready():
	self.type = Affiliation.BUILDING_TYPE_BASE
	self.damage_type_multipliers = [1, 1, 1]

#func _process(delta):
#	pass


# =================================================================================================
# ============================= Functions overriden from Entity Class =============================
# =================================================================================================

func initialize_health() -> void:
	self.maximum_health = 100
	self.health = self.maximum_health

func set_cost() -> void:
# warning-ignore:unused_variable
	for i in range(self.affiliation.resources.size()):
		self.cost.append(10)

func die() -> void:
	pass

func set_affiliation_material() -> void:
	$Cube.set_material_override(affiliation.color_material)


# =================================================================================================
# ============================ Functions overriden from Building Class ============================
# =================================================================================================

func production_finish() -> void:
	var new_unit = affiliation.rpc_add_unit(production_selection, self.translation)
	new_unit.rpc_add_navigation_order_position(self.translation + Vector3(0, 0, 2))
	self.production_timer.stop()
