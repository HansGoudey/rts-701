extends Node

var parent: Unit = null
var entity: Entity = null

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	entity = parent.get_parent()
	initialize_health()
	
func initialize_health():
	entity.health = 100
	entity.maximum_health = 100

func action_complete(type: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
