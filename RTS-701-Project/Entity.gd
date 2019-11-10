extends Spatial

class_name Entity

# Affiliation (Should be the parent of this node)
var affiliation:Affiliation

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
var select_circle:Spatial

func _ready():
	affiliation = self.get_parent()

	set_cost()

	if not check_cost_and_resources():
		return

	for i in range(affiliation.resources.size()):
		affiliation.rpc_change_resource(i, -cost[i])

	initialize_health()

	# Add a circle the size of the mesh below it to show when the entity is selected
	# TODO: Change this to something that looks better. Maybe another material or a mesh
	#       specific to each entity type
	var mesh:MeshInstance = get_child(0).get_child(0)
	var entity_size:Vector3 = mesh.get_transformed_aabb().size
	var circle_size:float = max(entity_size.x, entity_size.z)

	var select_circle_scene = load("res://UI/SelectCircle.glb")
	select_circle = select_circle_scene.instance()
	select_circle.scale = Vector3(circle_size, 1, circle_size)
	select_circle.set_visible(false)
	add_child(select_circle, true)

func check_cost_and_resources() -> bool:
	for i in range(affiliation.resources.size()):
		if cost[i] > affiliation.resources[i]:
			return false
	return true

func change_health(health:int, type:int) -> void:
	self.health -= health * damage_type_multipliers[type]

	if health < 0:
		die()
		self.free()
	elif health > maximum_health:
		# TODO: Special behaviour when over maximum health?
		pass

func select() -> void:
	if selected:
		return # Entity is already selected
	selected = true
	select_circle.set_visible(true)

func deselect() -> void:
	if not selected:
		return # Entity was not selected
	selected = false
	select_circle.set_visible(false)


# =================================================================================================
# =========== Override methods for functionality specific to specific types of entities ===========
# =================================================================================================

func set_cost() -> void:
	pass

func initialize_health() -> void:
	pass

func die() -> void:
	pass
