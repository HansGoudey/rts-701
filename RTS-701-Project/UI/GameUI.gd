extends Control

class_name GameUI

# References for ease of use
var player = null # TODO: Type this
var affiliation:Affiliation = null

# Actions Panel Controls
var visible_panel:Panel = null
var visible_panel_type:int = 0
enum {PANEL_NONE, PANEL_UNIT_ARMY, PANEL_UNIT_WORKER, PANEL_BUILDING_BASE, PANEL_BUILDING_ARMY}
var panel_type_map = {PANEL_NONE:-1,
					PANEL_UNIT_ARMY:Affiliation.UNIT_TYPE_ARMY,
					PANEL_UNIT_WORKER:Affiliation.UNIT_TYPE_WORKER,
					PANEL_BUILDING_BASE:Affiliation.BUILDING_TYPE_BASE,
					PANEL_BUILDING_ARMY:Affiliation.BUILDING_TYPE_ARMY}
signal place_building_pressed(type)
signal building_production_start(building_type, production_type)

func _ready():
	player = get_parent()
	affiliation = player.get_parent()

	# Connect action signals
	$ActionsWorker/PlaceBase.connect("button_down", self,
	                                 "place_building_pressed", [Affiliation.BUILDING_TYPE_BASE])
	$ActionsWorker/PlaceArmy.connect("button_down", self,
	                                 "place_building_pressed", [Affiliation.BUILDING_TYPE_ARMY])
	$ActionsBase/CreateWorker.connect("button_down", self,
	                                  "production_start_pressed", [Affiliation.UNIT_TYPE_WORKER])
	$ActionsArmy/CreateArmy.connect("button_down", self,
	                                  "production_start_pressed", [Affiliation.UNIT_TYPE_ARMY])
	assert(affiliation.connect("resource_0_change", self, "set_resource_text") == OK)
	assert(affiliation.connect("resource_1_change", self, "set_resource_text") == OK)
	assert(affiliation.connect("resource_2_change", self, "set_resource_text") == OK)
	set_resource_text()

func set_resource_text():
	var affiliation:Affiliation = get_parent().get_parent()
	for i in range(affiliation.resources.size()):

		var label:Label = get_node("Information/Resource" + str(i) + "/Value")
		label.text = str(affiliation.resources[i])

# Needed because we don't want the panels hidden in the editor
func hide_actions_panels():
	$ActionsWorker.set_visible(false)
	$ActionsArmyUnit.set_visible(false)
	$ActionsBase.set_visible(false)
	$ActionsArmy.set_visible(false)
	visible_panel_type = PANEL_NONE

func set_panel_visibility(type:int):
	if visible_panel:
		visible_panel.set_visible(false)
	if type == PANEL_NONE:
		visible_panel_type = PANEL_NONE
	elif type == PANEL_UNIT_WORKER:
		$ActionsWorker.set_visible(true)
		visible_panel_type = PANEL_UNIT_WORKER
	elif type == PANEL_UNIT_ARMY:
		$ActionsArmyUnit.set_visible(true)
		visible_panel_type = PANEL_UNIT_ARMY
	elif type == PANEL_BUILDING_BASE:
		$ActionsBase.set_visible(true)
		visible_panel_type = PANEL_BUILDING_BASE
	elif type == PANEL_BUILDING_ARMY:
		$ActionsArmy.set_visible(true)
		visible_panel_type = PANEL_BUILDING_ARMY

func place_building_pressed(type:int):
	emit_signal("place_building_pressed", type)

func production_start_pressed(production_type:int):
	var building_type:int = panel_type_map[visible_panel_type]
	emit_signal("building_production_start", building_type, production_type)
