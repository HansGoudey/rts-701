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
	assert(get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected") == OK)
	assert(get_tree().connect("connected_to_server", self, "connected_to_server") == OK)
	assert(get_tree().connect("connection_failed", self, "connection_failed") == OK)
	assert(get_tree().connect("server_disconnected", self, "server_disconnected") == OK)

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
	affiliation.add_player(player)
	affiliation.add_child(player)
	player.affiliation = affiliation
	player.assign_count += 1
	emit_signal("lobby_ui_update")

# Return the player node associated with a network peer ID
func get_player(id:int) -> Player:
	return player_info[id]

func rpc_add_player(peer_id:int, affiliation:Affiliation, id:String) -> Player:
	rpc("add_player", peer_id, affiliation, id)
	return add_player(peer_id, affiliation, id)

# Instance a player scene, map the network peer ID to it, and return it
# Doesn't contain a 'name' argument because the unique peer ID is appended to the name, so it's consistent
remote func add_player(peer_id:int, affiliation:Affiliation, id:String) -> Player:
	print("Add Player with ID ", id, " for ", peer_id, " to affiliation ID ", affiliation.id)
	var player_scene = load("res://Player.tscn")
	var player_node:Player = player_scene.instance()
	player_node.set_name("Player" + str(peer_id))
	player_node.set_network_master(peer_id)
	player_node.id = id
	assign_player_to_affiliation(player_node, affiliation)

	player_info[peer_id] = player_node
	assert(player_node.connect("ready_to_start", self, "check_game_start_lobby") == 0)

	emit_signal("lobby_ui_update")
	return player_node

# Adds a new affiliation node with the same name to all peers
func rpc_add_affiliation(color:Color, id:String) -> Affiliation:
	var new_affiliation_node:Affiliation = add_affiliation(color, id, "")
	rpc("add_affiliation", color, id, new_affiliation_node.get_name())
	return new_affiliation_node

# Adds an affiliation with a set name if it is supplied as a not-empty string
remote func add_affiliation(color:Color, id:String, name:String) -> Affiliation:
	print("Add Affiliation")
	var affiliation_scene = load("res://Affiliation.tscn")
	var affiliation_node:Affiliation = affiliation_scene.instance()
	affiliations.append(affiliation_node)
	affiliation_node.set_network_master(1)
	affiliation_node.id = id
	affiliation_node.color = color
	if name != "":
		affiliation_node.set_name(name)
	add_child(affiliation_node) # Add the affiliations as a child of Main for now, transfer them to Game later

	emit_signal("lobby_ui_update")
	return affiliation_node

# Removes an affiliation on all peers
func rpc_remove_affiliation(affiliation:Affiliation) -> void:
	remove_affiliation(affiliation)
	rpc("remove_affiliation", affiliation)

# Removes an affiliation if there is more than one, reassigning its players to another
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
remote func remove_player(peer_id:int) -> void:
	print("Remove Player of peer id ", peer_id)
	var player:Player = get_player(peer_id)
	if not player:
		print("ERROR (remove_player): No player found with peer id ", peer_id, "")
		return
	player.affiliation.players.erase(player)
	player.queue_free()
	player_info[peer_id] = null

	emit_signal("lobby_ui_update")

# Start the game scene with the terrain, freeing the lobby UI
remote func start_game():
	print("Start Game")
	# Load game scene
	var game_scene = load("res://Game.tscn")
	var game_node = game_scene.instance()
	add_child(game_node)
	$LobbyUI.queue_free()

	# Pass the affiliations and players list to the game
	game_node.affiliations = self.affiliations.duplicate()
	self.affiliations = null

	# Add the game UI for the player
	get_player(get_tree().get_network_unique_id()).load_ui()

	game_node.start_game()

# Start the lobby scene to set up the game, freeing the start UI
func start_lobby():
	print("Start Lobby")
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
	print("Host Game")
	# Create the network peer as a server
	var peer:NetworkedMultiplayerPeer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	self_id = 1

	# Create one affiliation to start with
	var affiliation:Affiliation = add_affiliation(Color(1, 0, 0), "Affiliation 1", "")

	# Add player and add it to the affiliation
	get_start_ui_player_name()
	var player:Player = add_player(1, affiliation, player_name_from_title)
	player_info[1] = player

	start_lobby()

func join_game() -> void:
	print("Join Game")
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

remote func set_player_id_from_start_ui():
	var my_player:Player = get_player(get_tree().get_network_unique_id())
	my_player.rpc_set_id(player_name_from_title)

# TODO: Should build the tree with the same nodes as the server. Maybe combine the "id" field with the
#       name somehow, making sure it's unique
func network_peer_connected(new_peer_id):
	print("Network Peer Connected with new id ", new_peer_id)
	if get_tree().is_network_server():
		# Set up the current tree for a newly joined player
		print("  Giving new peer existing tree")
		for child in get_children():
			if child is Affiliation:
				# Add each affiliation to the new peer
				var affiliation = child as Affiliation
				print("    Adding affiliation (ID: " + affiliation.id + ")")
				rpc_id(new_peer_id, "add_affiliation", affiliation.color, affiliation.id, affiliation.get_name())

				# Add that affiliation's players
				for aff_child in affiliation.get_children():
					if aff_child is Player:
						var player = aff_child as Player
						print("    Adding player (ID:", player.id, ", Affiliation: ", player.affiliation, ")")
						rpc_id(new_peer_id, "add_player", player.get_network_master(), player.affiliation, player.id)

		# Add a new affiliation and player to the newly joined peer
		var new_affiliation:Affiliation = rpc_add_affiliation(Color(randf(), randf(), randf()), "New Affiliation")
		rpc_add_player(new_peer_id, new_affiliation, "TEMP ID")
		rpc_id(new_peer_id, "set_player_id_from_start_ui")

func network_peer_disconnected(id):
	# Get a unique affiliation name from the server
	print("Network Peer Disconnected")
	if get_tree().is_network_server():
		remove_player(id)
		rpc("remove_player", id)

func connected_to_server():
	pass

func connection_failed():
	pass

func server_disconnected():
	pass
