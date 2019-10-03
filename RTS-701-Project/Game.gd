extends Spatial

# Affiliations
var n_affilations: int = 0
var affiliations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var affi_scene = load("res://Affiliation.tscn")
	var affi_node = affi_scene.instance()
	affiliations.append(affi_node)
	add_child(affi_node)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
