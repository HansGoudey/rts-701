extends Node

# TODO: Add the rest of the rpc_* functions where there needed (used for calling from signals like from LobbyUI)
# TODO: See if it's possible to move the player and affiliation functions to their respective scripts

class_name Main

const SERVER_PORT:int = 56789
const MAX_PLAYERS:int = 10

# Lobby Networking Information
var self_id:int = 0
var player_info = {} # {id: Player node}
var player_name_from_title:String = ""
var affiliations = [] # Only used during lobby phase, Game stores them after that
var connected_success: bool = false
signal lobby_ui_update

func _ready():
	# Load start UI and connect its signals
	var ui_scene = load("res://UI/StartUI.tscn")
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
		
func rpc_assign_player_to_affiliation(player:Player, affiliation:Affiliation) -> void:
	assign_player_to_affiliation(player, affiliation)
	rpc("assign_player_to_affiliation", player, affiliation)

remote func assign_player_to_affiliation(player:Player, affiliation:Affiliation) -> void:
	print("Assign Player to Affiliation")
	# Remove this player from the affiliation its current one
	if player.affiliation: 
		player.affiliation.players.erase(player)
		player.affiliation.remove_child(player)

	# Add the player to the specified affiliation
	affiliation.players.append(player)
	affiliation.add_child(player)
	player.affiliation = affiliation
	player.assign_count += 1
	emit_signal("lobby_ui_update")

# Return the player node associated with a network peer ID
func get_player(id:int) -> Player:
	return player_info[id]

# Instance a player scene, map the network peer ID to it, and return it
remote func add_player(peer_id:int, affiliation:Affiliation, id:String) -> Player:
	print("Add Player")
	var player_scene = load("res://Player.tscn")
	var player_node:Player = player_scene.instance()
	player_node.set_name("Player" + str(peer_id))
	player_node.set_network_master(peer_id)
	player_node.id = id
	assign_player_to_affiliation(player_node, affiliation)

	player_info[id] = player_node
	assert(player_node.connect("ready_to_start", self, "check_game_start_lobby") == 0)

	emit_signal("lobby_ui_update")
	return player_node
	
func rpc_add_affiliation(color:Color, id:String) -> Affiliation:
	rpc("add_affiliation", color, id)
	return add_affiliation(color, id)

remote func add_affiliation(color:Color, id:String) -> Affiliation:
	print("Add Affiliation")
	var affiliation_scene = load("res://Affiliation.tscn")
	var affiliation_node:Affiliation = affiliation_scene.instance()
	affiliations.append(affiliation_node)
	affiliation_node.set_network_master(1)
	affiliation_node.id = id
	affiliation_node.color = color

	emit_signal("lobby_ui_update")
	return affiliation_node
	
remote func remove_affiliation_string(name:String) -> void:
	var affiliation_node:Affiliation = find_node(name, false, true)
	remove_affiliation(affiliation_node)

func rpc_remove_affiliation(affiliation:Affiliation) -> void:
	remove_affiliation(affiliation)
	rpc("remove_affiliation", affiliation)

remote func remove_affiliation(affiliation_node:Affiliation) -> void:
	print("Remove Affiliation")
	# Ensure node is found and is an existing Affiliation
	if not affiliation_node:
		return
	if not affiliation_node is Affiliation:
		return
	if affiliations.size() == 1: # Do not allow deleting the last affiliation
		return
		
	# Find the affiliation in the list 
	var i_to_delete:int = 0
	for i in range(affiliations.size()):
		if affiliations[i] == affiliation_node:
			i_to_delete = i # location of the affiliation to delete in list
			break
		
	var i_to_move_to:int = 1 if i_to_delete == 0 else i_to_delete - 1;
	
	var successor:Affiliation = affiliations[i_to_move_to]
	
	for player in affiliation_node.players:
		assign_player_to_affiliation(player, successor)
	
	affiliations.erase(affiliation_node)
	
	affiliation_node.queue_free()
	
	emit_signal("lobby_ui_update")

# Remove a player from the global list and free it
remote func remove_player(id:int) -> void:
	print("Remove Player")
	var player:Player = get_player(id)
	player.affiliation.players.erase(player)
	player.queue_free()
	player_info[id] = null
	
	emit_signal("lobby_ui_update")

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
	var lobby_scene = load("res://UI/LobbyUI.tscn")
	var lobby_node = lobby_scene.instance()
	add_child(lobby_node)
	$StartUI.queue_free()

# In some cases the text box used to set the name is freed before we create the player,
# so store the name in a variable temporarily so we can use it
func get_start_ui_player_name() -> void:
	var name_field:TextEdit = $StartUI/NameField
	player_name_from_title = name_field.text

func host_game() -> void:
	# Create the network peer as a server
	var peer:NetworkedMultiplayerPeer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	self_id = 1

	# Create one affiliation to start with
	var affiliation:Affiliation = add_affiliation(Color(1, 0, 0), "Affiliation 1")

	# Add player and add it to the affiliation
	get_start_ui_player_name()
	var player:Player = add_player(1, affiliation, player_name_from_title)
	player_info[1] = player

	start_lobby()

func join_game() -> void:
	# Get IP to connect to from text field
	var ui_node:Control = $StartUI
	var ip_field:TextEdit = ui_node.find_node("IPField", false)
	var server_ip:String = ip_field.text

	# Create the network peer as a client
	var tree:SceneTree = get_tree()
	if tree.has_network_peer():
		tree.set_network_peer(null)
	
	var peer:NetworkedMultiplayerPeer = NetworkedMultiplayerENet.new()
	var error:int = peer.create_client(server_ip, SERVER_PORT)
	if error == OK:
		tree.set_network_peer(peer)
		self_id = tree.get_network_unique_id()
		get_start_ui_player_name()
		start_lobby()
	elif error == ERR_ALREADY_IN_USE:
		print("Network peer already in use, retrying")
		peer.close_connection()
		join_game()
	elif error == ERR_CANT_CREATE:
		print("Can't create connection")

func network_peer_connected(id):
	print("Network Peer Connected")
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
		add_player(self_id, new_affiliation, player_name_from_title)
		rpc("add_player", self_id, new_affiliation, player_name_from_title)
		connected_success = true

func network_peer_disconnected(id):
	print("Network Peer Disconnected")
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
