extends Control

#var player:Player = null

signal place_building_pressed
signal place_unit_pressed

func _ready():
	var affiliation:Affiliation = get_parent().get_parent()
	# Connect action signals
	assert($Actions/PlaceBuilding.connect("button_down", self, "place_building_pressed") == OK)
	assert($Actions/PlaceUnit.connect("button_down", self, "place_unit_pressed") == OK)
	assert(affiliation.connect("resource_0_change", self, "set_resource_text") == OK)
	assert(affiliation.connect("resource_1_change", self, "set_resource_text") == OK)
	assert(affiliation.connect("resource_2_change", self, "set_resource_text") == OK)
	set_resource_text()

func set_resource_text():
	var affiliation:Affiliation = get_parent().get_parent()
	for i in range(affiliation.resources.size()):

		var label:Label = get_node("Information/Resource" + str(i) + "/Value")
		label.text = str(affiliation.resources[i])

func place_building_pressed():
	emit_signal("place_building_pressed")

func place_unit_pressed():
	emit_signal("place_unit_pressed")