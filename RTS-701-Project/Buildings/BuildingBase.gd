extends Building

signal check_building_bases

func _ready():
	self.type = Affiliation.BUILDING_TYPE_BASE
	self.maximum_health = 100
	self.health = maximum_health
	self.damage_type_multipliers = [1, 1, 1]
	
	assert(self.connect("check_building_bases", get_node("/root/Main"), "kick_players") == OK)
	
	add_to_group(get_parent().get_name()+"bases")
	
var dead = false

func _process(delta):
	
	if health == 0 and not dead:
		die()

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
	# home base of affiliation is dead
	# free the affiliation
	dead = true
	remove_from_group(get_parent().get_name() + "bases")
	emit_signal("check_building_bases", get_parent())
	self.queue_free()
	
	

func set_affiliation_material() -> void:
	$Cube.set_material_override(affiliation.color_material)


# =================================================================================================
# ============================ Functions overriden from Building Class ============================
# =================================================================================================

func production_finish() -> void:
	print("Production Finished")
	var new_unit = affiliation.rpc_add_unit(production_selection, self.translation)
	new_unit.rpc_add_navigation_order_position(self.translation + Vector3(0, 0, 2))
	self.production_timer.stop()
