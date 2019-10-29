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
var cost = []

func _ready():
	affiliation = self.get_parent()

func _process(delta):
	pass

func damage(health:int, type:int):
	self.health -= health * damage_type_multipliers[type]
	
	if health < 0:
		self.free()
		
func _exit_tree():
	pass