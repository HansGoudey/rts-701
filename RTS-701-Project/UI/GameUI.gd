extends Control

#var player:Player = null

signal place_building
signal place_entity

func _ready():
	# Connect action signals
	assert($Actions/PlaceBuilding.connect("button_down", self, "place_building_pressed") == OK)
	assert($Actions/PlaceEntity.connect("button_down", self, "place_entity_pressed") == OK)

func place_building_pressed():
	emit_signal("place_building")

func place_entity_pressed():
	emit_signal("place_entity")