extends Control

func _ready():
	$JoinGame.connect("pressed", self, "_on_JoinButton_Pressed")
	$HostGame.connect("pressed", self, "_on_HostButton_Pressed")

signal host_game
signal join_game

func _on_JoinButton_Pressed():
	emit_signal("join_game")
	
func _on_HostButton_Pressed():
	emit_signal("host_game")
