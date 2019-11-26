extends Node

class_name Affiliation

# ID / Color
var id:String = ""
var color:Color = Color(0.0, 0.0, 0.0, 1.0)
signal color_updated(color)

# Resource Counts
var resources = []
signal resource_0_change
signal resource_1_change
signal resource_2_change


# Linked Player Nodes
# warning-ignore:unused_class_variable
var players = []

# Visible Area (Fog of war)

# Building Types
enum {BUILDING_TYPE_BASIC = 0,}

# Unit Types
enum {UNIT_TYPE_BASIC = 0,}

func _ready() -> void:
	resources = [100, 100, 100]


func rpc_set_color_from_hue(hue:float) -> void:
	set_color_from_hue(hue)
	rpc("set_color_from_hue", hue)

remote func set_color_from_hue(hue:float) -> void:
	var color:Color = Color.from_hsv(hue, 0.75, 1)
	set_color(color)

remote func set_color(color:Color) -> void:
	emit_signal("color_updated", color)
	self.color = color

remote func set_id(id:String) -> void:
	self.id = id

func rpc_change_resource(which:int, amount:float) -> void:
	change_resource(which, amount)
	rpc("change_resource", which, amount)

remote func change_resource(which:int, amount:float) -> void:
#	print("Change resource: ", which, " by ", amount)
	assert(which < resources.size())
	resources[which] += amount
	if which == 0:
		emit_signal("resource_0_change")
	elif which == 1:
		emit_signal("resource_1_change")
	elif which == 2:
		emit_signal("resource_2_change")

func assign_player(player):
	if players:
		players.append(player)
	else:
		players = [player]

# Add a building across all peers, keeping a consistent name
func rpc_add_building(type:int, position:Vector3) -> void:
	var new_building = add_building(type, position, "")
	rpc("add_building", type, position, new_building.name)

# TODO: Want to use 'Building' and 'Unit' types but cyclic dependency error-- figure that out
remote func add_building(type:int, position:Vector3, name:String):
	var building_scene
	if type == BUILDING_TYPE_BASIC:
		building_scene = load("res://Buildings/BuildingBasic.tscn")
	var building_node = building_scene.instance()
	building_node.translate(position)
	if name != "":
		building_node.set_name(name)
	add_child(building_node, true)

	# TODO: Add a cut into the map's 2D navigation polygon so they are avoided for navigation

	return building_node

func rpc_add_unit(type:int, position:Vector3):
	var new_unit = add_unit(type, position, "")
	rpc("add_unit", type, position, new_unit.name)

remote func add_unit(type:int, position:Vector3, name:String):
	var unit_scene
	if type == BUILDING_TYPE_BASIC:
		unit_scene = load("res://Units/UnitBasic.tscn")
	var unit_node = unit_scene.instance()
	unit_node.translate(position)
	if name != "":
		unit_node.set_name(name)
	add_child(unit_node, true)

	return unit_node

