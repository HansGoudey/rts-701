extends Spatial

class_name Entity

# Affiliation (Should be an ancestor of this node)

# Health

# Maximum Health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func damage(health, type):
	self.health -= health
	
	if health < 0:
		self.free()
		
func _exit_tree():
	pass