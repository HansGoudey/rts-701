extends Unit

# If resource falls within the (action_range, RADIUS_MULTIPLIER*action_range]
# the worker will place a navigation order for itself
var RADIUS_MULTIPLIER = 2

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
	var map = get_node('/root/Main/Game/Map')
	var sqrd_range = 2 * self.action_range
	for resource in map.resources:
		# TODO: unsure if the action range is a squared distance or not..
		var dist = get_translation().distance_squared_to(resource[1])
		if self.action_range < dist and dist <= RADIUS_MULTIPLIER*self.action_range:
			self.orders.push_back([ORDER_NAVIGATION_POSITION, resource[1]])
		elif dist <= self.action_range:
			# Have the worker attack
			print('going to attack')
			#attack(resource[1]) # need to keep the node instead of the resource
			#					# and position... woops

func attack(node):
	pass

func action_complete(type:int):
	pass

func set_movement_information():
	self.acceleration = 2.0
	self.velocity_decay_rate = 0.90

func set_action_range():
	self.action_range = 4.0
