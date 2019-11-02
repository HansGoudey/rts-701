extends Control

#var player:Player = null

signal place_building_pressed
signal place_unit_pressed

func _ready():
	# Connect action signals
	assert($Actions/PlaceBuilding.connect("button_down", self, "place_building_pressed") == OK)
	assert($Actions/PlaceUnit.connect("button_down", self, "place_unit_pressed") == OK)

func place_building_pressed():
	emit_signal("place_building_pressed")

func place_unit_pressed():
	emit_signal("place_unit_pressed")