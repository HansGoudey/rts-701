extends Node

class_name Main

const SERVER_PORT:int = 56789
const MAX_PLAYERS:int = 10

# Lobby Networking Information
var self_id:int = 0
var player_info = {} # {id: Player node}
var affiliations = [] # Only used during lobby phase, game stores
signal add_player
signal add_affiliation

func _ready():
	# Load start UI and connect its signals
	var ui_scene = load("res://StartUI.tscn")
	var ui_node:Control = ui_scene.instance()
	add_child(ui_node)
	assert(ui_node.connect("host_game", self, "host_game") == OK)
	assert(ui_node.connect("join_game", self, "join_game") == OK)

	# Connect networking functions
	assert(get_tree().connect("network_peer_connected", self, "network_peer_connected") == OK)
	assert(get_tree().connect("network_peer_disconnected", self, "_player_disconnected") == OK)
	assert(get_tree().connect("connected_to_server", self, "_connected_ok") == OK)
	assert(get_tree().connect("connection_failed", self, "_connected_fail") == OK)
	assert(get_tree().connect("server_disconnected", self, "_server_disconnected") == OK)

# In the lobby, start the game if all players are ready 
func check_game_start_lobby() -> void:
	var all_players_ready:bool = true
	for player_node in player_info.values():
		if not player_node.ready_to_start:
			all_players_ready = false
			break
	if all_players_ready:
		start_game()
		rpc("start_game")

remote func assign_player_to_affiliation(player:Player, affiliation:Affiliation) -> void:
	# Remove this player from the affiliation its current one
	if player.affiliation: 
		player.affiliation.players.erase(player)

	# Add the player to the specified affiliation
	affiliation.players.append(player)
	affiliation.add_child(player)
	player.affiliation = affiliation

# Return the player node associated with a network peer ID
func get_player(id:int) -> Player:
	return player_info[id]

# Instance a player scene, map the network peer ID to it, and return it
remote func add_player(peer_id:int, affiliation:Affiliation, id:String) -> Player:
	var player_scene = load("res://Player.tscn")
	var player_node:Player = player_scene.instance()
	player_node.set_name("Player" + str(peer_id))
	player_node.set_network_master(peer_id)
	player_node.id = id
	assign_player_to_affiliation(player_node, affiliation)

	player_info[id] = player_node
	assert(player_node.connect("ready_to_start", self, "check_game_start_lobby") == 0)

	emit_signal("add_player")
	return player_node

remote func add_affiliation(color:Color, id:String) -> Affiliation:
	print("Add Affiliation")
	var affiliation_scene = load("res://Affiliation.tscn")
	var affiliation_node:Affiliation = affiliation_scene.instance()
	affiliations.append(affiliation_node)
	affiliation_node.set_network_master(1)
	affiliation_node.id = id
	affiliation_node.color = color

	emit_signal("add_affiliation")
	return affiliation_node

remote func remove_affiliation(name:String) -> void:
	var affiliation_node:Affiliation = find_node(name, false, true)
	
	# TODO: Move this affiliation's players to another affiliation and don't allow deleting the last one
	
	if affiliation_node:
		# TODO: Probably should check the type of the object it found
		affiliation_node.queue_free()

# Remove a player from the global list and free it
remote func remove_player(id:int) -> void:
	var player:Player = get_player(id)
	player.affiliation.players.erase(player)
	player.queue_free()
	player_info[id] = null

# Start the game scene with the terrain, freeing the lobby UI
remote func start_game():
	# Load game scene
	var game_scene = load("res://Game.tscn")
	var game_node = game_scene.instance()
	add_child(game_node)
	$LobbyUI.queue_free()

	# Pass the affiliations and players list to the game
	game_node.affiliations = self.affiliations.duplicate()
	self.affiliations = null
	
	game_node.start_game()

# Start the lobby scene to set up the game, freeing the start UI
func start_lobby():
	# Load lobby scene
	var lobby_scene = load("res://LobbyUI.tscn")
	var lobby_node = lobby_scene.instance()
	add_child(lobby_node)
	$StartUI.queue_free()

func get_start_ui_player_name() -> String:
	var name_field:TextEdit = $StartUI/NameField
	return name_field.text

func host_game() -> void:
	# Create the network peer as a server
	var peer:NetworkedMultiplayerPeer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	self_id = 1

	# Create one affiliation to start with
	var affiliation:Affiliation = add_affiliation(Color(1, 0, 0), "Affiliation 1")

	# Add player and add it to the affiliation
	var player:Player = add_player(1, affiliation, get_start_ui_player_name())
	player_info[1] = player

	start_lobby()

func join_game() -> void:
	# Get IP to connect to from text field
	var ui_node:Control = $StartUI
	var ip_field:TextEdit = ui_node.find_node("IPField", false)
	var server_ip:String = ip_field.text

	# Create the network peer as a client
	var peer:NetworkedMultiplayerPeer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, SERVER_PORT)
	get_tree().set_network_peer(peer)
	self_id = get_tree().get_network_unique_id()

	start_lobby()

func network_peer_connected(id):
	if get_tree().is_network_server():
		# Set up the current tree for a newly joined player
		for child in get_children():
			if child is Affiliation:
				var affiliation = child as Affiliation
				rpc_id(id, "add_affiliation", affiliation.color, affiliation.id)
				for aff_child in affiliation.get_children():
					if aff_child is Player:
						var player = child as Player
						rpc_id(id, "add_player", player.get_network_master(), player.affiliation, player.id)
	else:
		# Add a new player for the player that just joined
		var new_affiliation:Affiliation = add_affiliation(Color(randf(), randf(), randf()), "New Affiliation")
		rpc("add_affiliation", Color(randf(), randf(), randf()), "New Affiliation")
		# warning-ignore:return_value_discarded
		add_player(self_id, new_affiliation, get_start_ui_player_name())
		rpc("add_player", self_id, new_affiliation, get_start_ui_player_name())

func network_peer_disconnected(id):
	remove_player(id)
	if get_tree().is_network_server():
		remove_player(id)
		rpc("remove_player", id)

func connected_to_server():
	pass

func connection_failed():
	pass

func server_disconnected():
	pass
