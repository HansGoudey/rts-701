extends Entity

class_name Building

# Building Type
# warning-ignore:unused_class_variable
var type:int = 0

# TODO: Building units takes twice as much resources as it should

# Production State (Countdown or position in production process)
var production_selection:int = 0 # TODO: Use separate enum for profuction type
var production_timer:Timer = null

func _ready():
	# TODO: Create a new timer every time start production is called
	production_timer = Timer.new()
	add_child(production_timer)
	# warning-ignore:return_value_discarded
	if get_tree().is_network_server():
		production_timer.connect("timeout", self, "production_finish")
	add_to_group("targets") # TODO: Better group names and more extensive use of groups

#func _process(delta):
#	pass

func rpc_start_production(production_type:int):
	start_production(production_type)
	rpc("start_production", production_type)

remote func start_production(production_type:int):
	production_selection = production_type
	production_timer.start(2.0)


# =================================================================================================
# ========== Override methods for functionality specific to specific types of buildings ===========
# =================================================================================================

func production_finish() -> void:
	pass
