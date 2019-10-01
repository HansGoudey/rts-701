extends Spatial

class_name Entity

# Affiliation (Should be an ancestor of this node)
var Affiliation: Affilation

# Health
var health: int = 0
var maximum_health: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	load

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func damage(health: int, type):
	self.health -= health
	
	if health < 0:
		self.free()
		
func _exit_tree():
	pass