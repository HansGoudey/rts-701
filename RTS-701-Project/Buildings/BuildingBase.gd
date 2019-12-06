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
	remove_from_group("Entities")

	# TODO: Move this functionality to Entity.gd
	var particles_scene = preload("res://DeathParticles.tscn")
	var particles_node = particles_scene.instance()
	particles_node.translation = self.translation
	map.add_child(particles_node)
	particles_node.restart()

func set_affiliation_material() -> void:
	$Cube.set_material_override(affiliation.color_material)


# =================================================================================================
# ============================ Functions overriden from Building Class ============================
# =================================================================================================

func production_finish() -> void:
	print("Production Finish")
	var new_unit:Unit = affiliation.rpc_add_unit(production_selection, self.translation)
	new_unit.rpc_add_navigation_order_position(self.translation + Vector3(0, 0, 2))
	self.production_timer.stop()
