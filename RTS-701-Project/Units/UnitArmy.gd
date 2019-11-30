extends Unit

var RADIUS_MULTIPLIER: int = 2

# Damage amount
var DAMAGE: int = 2

func _ready():
	self.type = Affiliation.UNIT_TYPE_ARMY
	self.damage_type_multipliers = [1, 1, 1]

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

# TODO: should each unit go through every other affiliation?
func default_action():
	var main_children = get_node('/root/Main').get_children()
	for child in main_children:
		if child is Affiliation:
			if child == affiliation: # do not look at your own affiliation
				continue
			var affiliation_children = child.get_children()
			for aff_child in affiliation_children:
				if not (aff_child is Entity):
					continue
				var aff_child_pos = aff_child.get_translation()
				var dist = get_translation().distance_squared_to(aff_child_pos)
				if self.action_range < dist and dist <= RADIUS_MULTIPLIER*self.action_range:
					self.orders.push_back([ORDER_NAVIGATION_POSITION, aff_child_pos])
				elif dist <= self.action_range:
					attack(aff_child)

func attack(node):
	while self.health > 0 and not node.is_dead():
		node.change_health(DAMAGE, 1) # TODO: should make these constants
	
	if node.is_dead():
		node.queue_free()

func action_complete(type:int):
	pass

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0
