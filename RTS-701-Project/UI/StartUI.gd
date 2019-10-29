extends Control

func _ready():
	assert($JoinGame.connect("pressed", self, "_on_JoinButton_Pressed") == OK)
	assert($HostGame.connect("pressed", self, "_on_HostButton_Pressed") == OK)

signal host_game
signal join_game

func _on_JoinButton_Pressed():
	emit_signal("join_game")
	
func _on_HostButton_Pressed():
	emit_signal("host_game")
