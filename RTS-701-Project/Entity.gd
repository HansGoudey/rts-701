extends Spatial

class_name Entity

# Affiliation (Should be the parent of this node)
var affiliation: Affiliation

# Health
var health:int = 0
var maximum_health:int = 0

# Damage
enum DamageTypes {DMG_SPASH = 0, DMG_DIRECT = 1, DMG_MELEE = 2}
var damage_type_multipliers = []

# Resources
# warning-ignore:unused_class_variable
var cost = []

# Selection by Player
var selected:bool = false

func _ready():
	add_entity()
	rpc("add_entity")

remote func add_entity():
	affiliation = self.get_parent()
	set_cost()
	for i in range(affiliation.resources.size()):
		affiliation.change_resource(i, cost[i])
	initialize_health()

func _process(delta):
	if selected:
		pass
		# Show a difference

func change_health(health:int, type:int):
	self.health -= health * damage_type_multipliers[type]

	if health < 0:
		die()
		self.free()
	elif health > maximum_health:
		# Special behaviour when over maximum health?
		pass

# Override methods for functionality specific to specific types of entities

func set_cost() -> void:
	pass

func initialize_health() -> void:
	pass

func die() -> void:
	pass