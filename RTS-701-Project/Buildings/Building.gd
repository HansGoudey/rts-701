extends Entity

class_name Building

# Production State (Countdown or position in production process)
var production_selection:int = 0
var production_countdown:float = 0
var production_active:bool = 0

func _ready():
	pass

func _process(delta):
	# TODO: Use a timer
	if production_countdown > 0:
		production_countdown -= delta
	if production_countdown < 0:
		production_finished()


# =================================================================================================
# ========== Override methods for functionality specific to specific types of buildings ===========
# =================================================================================================

func production_finished() -> void:
	pass
