extends Unit

func _ready():
	type = Affiliation.UNIT_TYPE_ARMY
	damage_type_multipliers = [1, 1, 1]
	damage = 5

#func _process(delta):
#	pass


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
	remove_from_group("Entities")

	# TODO: Move this functionality to Entity.gd
	var particles_scene = preload("res://DeathParticles.tscn")
	var particles_node = particles_scene.instance()
	particles_node.translation = self.translation
	map.add_child(particles_node)
	particles_node.restart()

func set_affiliation_material() -> void:
	get_child(0).set_material_override(affiliation.color_material)


# =================================================================================================
# ============================== Functions overriden from Unit Class ==============================
# =================================================================================================

#func action_complete(type:int):
#	pass

func attack_finish():
	var target_node = get_target_node()
	if target_node:
		var wr:WeakRef
		if target_node:
			wr = weakref(target_node);
		if not wr.get_ref():
			pop_order()
		# Else deal damage based on the type of the target
		else:
			if target_node is Entity and target_node.affiliation != self.affiliation:
				target_node.change_health(damage, 1)
	attack_timer.stop()

func get_targets():
	# TODO: This is probably a very slow way of doing this
	var entities = get_tree().get_nodes_in_group("Entities")
	var return_array = []
	for entity in entities:
		if entity is Entity and entity.affiliation != self.affiliation:
			return_array.append(entity)
	return return_array

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0


