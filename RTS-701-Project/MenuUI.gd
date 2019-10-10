extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: get sign up done using something simple
	# 		it could be an existing authentification or 
	#		something simpler
	get_node("Menu/GridContainer/JoinServer").connect("pressed", self, "_on_StartButton_Pressed")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

signal start_game

func _on_StartButton_Pressed():
	# Probably load the game scene at first, then maybe add an options panel before that
	emit_signal("start_game")