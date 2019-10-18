extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("ActionsPanel/StartButton").connect("pressed", self, "_on_StartButton_Pressed")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

signal start_game
signal host_game
signal join_game

func _on_StartButton_Pressed():
	# Probably load the game scene at first, then maybe add an options panel before that
	emit_signal("start_game")