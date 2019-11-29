extends Unit

# If resource falls within the (action_range, RADIUS_MULTIPLIER*action_range]
# the worker will place a navigation order for itself
var RADIUS_MULTIPLIER: int = 2

# Damage amount
var DAMAGE: int = 2

func _ready():
	self.type = Affiliation.UNIT_TYPE_WORKER
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

func default_action():
	# Go though list of resources from the map and
	# check if they are in the action_range
	var map_children = get_node('/root/Main/Game/Map').get_children()
	var sqrd_range = 2 * self.action_range
	for child in map_children: # iterate over each node in the map
		# TODO: unsure if the action range is a squared distance or not..
		if not (child is MapResource):
			continue
		
		var resource_pos = child.get_translation()
		var dist = get_translation().distance_squared_to(resource_pos)
		if self.action_range < dist and dist <= RADIUS_MULTIPLIER*self.action_range:
			self.orders.push_back([ORDER_NAVIGATION_POSITION, resource_pos])
		elif dist <= self.action_range:
			# Have the worker attack
			attack(child)

func attack(node):
	# attack while this health is non zero and while the 
	# target is not dead
	while self.health > 0 and not node.is_dead():
		node.harvest(DAMAGE)
	
	# check that node was not killed and not just the unit 
	if node.is_dead():
		affiliation.change_resource(node.type, 1) # TODO: should be based on resource type
		node.die()

func action_complete(type:int):
	pass

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0
