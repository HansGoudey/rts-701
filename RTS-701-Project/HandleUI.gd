extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("ActionsPanel/StartButton").connect("pressed", self, "_on_StartButton_Pressed")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_StartButton_Pressed():
	# Probably load the game scene at first, then maybe add an options scene before that
	pass