extends Unit

func _ready():
	type = Affiliation.UNIT_TYPE_ARMY
	damage_type_multipliers = [1, 1, 1]

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
	pass

func attack():
	var target_node = get_navigation_target_node()
	if target_node:
		var wr:WeakRef
		if target_node:
			wr = weakref(target_node);
		if not wr.get_ref():
			pop_order()
		# Else deal damage based on the type of the target
		else:
			if target_node is Entity and target_node.get_parent() != get_parent():
				target_node.change_health(damage, 1)
	attack_timer.stop()


func set_affiliation_material() -> void:
	get_child(0).set_material_override(affiliation.color_material)

# =================================================================================================
# ============================== Functions overriden from Unit Class ==============================
# =================================================================================================

#func action_complete(type:int):
#	pass

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0
