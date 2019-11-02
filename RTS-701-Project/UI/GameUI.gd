extends Control

#var player:Player = null

signal place_building_pressed
signal place_unit_pressed

func _ready():
	var affiliation:Affiliation = get_parent().get_parent()
	# Connect action signals
	assert($Actions/PlaceBuilding.connect("button_down", self, "place_building_pressed") == OK)
	assert($Actions/PlaceUnit.connect("button_down", self, "place_unit_pressed") == OK)
	assert(affiliation.connect("resource_0_change", $Information/Resource1/Value, "set_text", [str(affiliation.resources[0])]) == OK)
	assert(affiliation.connect("resource_1_change", $Information/Resource2/Value, "set_text", [str(affiliation.resources[1])]) == OK)
	assert(affiliation.connect("resource_2_change", $Information/Resource3/Value, "set_text", [str(affiliation.resources[2])]) == OK)

func place_building_pressed():
	emit_signal("place_building_pressed")

func place_unit_pressed():
	emit_signal("place_unit_pressed")