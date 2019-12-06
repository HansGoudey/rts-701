
extends Spatial
class_name Entity

# Affiliation (Should be the parent of this node)
var affiliation:Affiliation

# Health
var health:int = 0
var maximum_health:int = 100
var health_bar:HealthBar = null

# Damage
enum DamageTypes {DMG_SPASH = 0, DMG_DIRECT = 1, DMG_MELEE = 2}
var damage_type_multipliers = [1,1,1]

# Resources
# warning-ignore:unused_class_variable
var cost = []

# Selection by Player
var selected:bool = false
var select_circle:Spatial

func _ready():
	affiliation = self.get_parent()

	set_cost()

	# Don't create entities if there aren't enough resources
	if not check_cost_and_resources():
		self.queue_free()
		return

	for i in range(affiliation.resources.size()):
		affiliation.change_resource(i, -cost[i])

	initialize_health()

	add_to_group("Entities", true)

	# TODO: Change this to something that looks better. Maybe another material or a mesh
	#       specific to each entity type
	var mesh:MeshInstance = get_child(0)
	var entity_size:Vector3 = mesh.get_transformed_aabb().size * 1.5

	add_select_circle(entity_size)

	set_affiliation_material()

	add_health_bar(entity_size)

func add_select_circle(entity_size:Vector3) -> void:
	var circle_size:float = max(entity_size.x, entity_size.z)

	var select_circle_scene = load("res://UI/SelectCircle.glb")
	select_circle = select_circle_scene.instance()
	select_circle.scale = Vector3(circle_size, 1, circle_size)
	select_circle.set_visible(false)
	add_child(select_circle, true)

func add_health_bar(entity_size) -> void:
	var health_bar_scene = load("res://UI/Health Bar/HealthBar.tscn")
	health_bar = health_bar_scene.instance()
	health_bar.translation = Vector3.UP * (entity_size)
	health_bar.set_material(affiliation.color_material)
	add_child(health_bar)

func check_cost_and_resources() -> bool:
	for i in range(affiliation.resources.size()):
		if cost[i] > affiliation.resources[i]:
			return false
	return true

func change_health(new_health:int, type:int) -> void:
	self.health -= new_health * damage_type_multipliers[type]

	health_bar.set_bar(float(self.health) / float(self.maximum_health))

	if self.health < 0:
		die()
		self.queue_free()
	elif health > maximum_health:
		# TODO: Special behaviour when over maximum health?
		pass

func select() -> void:
	if selected:
		return # Entity is already selected
	selected = true
	if select_circle:
		select_circle.set_visible(true)
	else:
		print("Entity has no select circle")

func deselect() -> void:
	if not selected:
		return # Entity was not selected
	selected = false
	if select_circle:
		select_circle.set_visible(false)
	else:
		print("Entity has no select circle")


# =================================================================================================
# =========== Override methods for functionality specific to specific types of entities ===========
# =================================================================================================

func set_cost() -> void:
	pass

func initialize_health() -> void:
	pass

func die() -> void:
	pass

func set_affiliation_material() -> void:
	pass
