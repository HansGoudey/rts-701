extends Node

class_name Affiliation

# ID / Color
var id:String = ""
var color:Color = Color(0.0, 0.0, 0.0, 1.0)

# Resource Counts
var resources = []

# Linked Player Nodes
# warning-ignore:unused_class_variable
var players = []

# Visible Area (Fog of war)

func _ready():
	pass

#func _process(delta):
#	pass

func set_color_from_hue(hue:float) -> void:
	var color:Color = Color.from_hsv(hue, 0.75, 1)
	set_color(color)

remote func set_color(color:Color) -> void:
	self.color = color

sync func set_id(id:String) -> void:
	self.id = id

remote func change_resource(which:int, amount:float) -> void:
	assert(which < resources.size())
	resources[which] += amount

func add_player(player):
	if players:
		players.append(player)
	else:
		players = [player]