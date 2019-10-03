extends Spatial

# Affiliations
var n_affilations: int = 0
var affiliations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var affiliation_scene = load("res://Affiliation.tscn")
	affiliations.append(affiliation_scene.instance())
	n_affilations = 1
	add_child(affiliations[0])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
