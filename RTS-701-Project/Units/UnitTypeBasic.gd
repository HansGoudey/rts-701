extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_health()
	
func initialize_health():
	var parent: Unit = get_parent()
	
	parent.health = 100
	parent.maximum_health = 100

func action_complete(type: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
