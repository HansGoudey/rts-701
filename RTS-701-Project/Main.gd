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
var connected_success:bool = false
var dedicated_server:bool = false
var game_started:bool = false
signal lobby_ui_update

var multiplayer_lock:int = 0 # Lock to prevent progress until all players have reached a certain state
signal multiplayer_lock_complete

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

	dedicated_server = cmd_args_exist()
	if dedicated_server: # if run on basin set host game
		host_game()

# In the lobby, start the game if all players are ready
func check_game_start_lobby() -> void:
	if not get_tree().is_network_server():
		return

	var all_players_ready:bool = true
	for player_node in player_info.values():

		if not player_node.ready_to_start:
			all_players_ready = false
			break

	# on basin, there should be at least be one other player in the lobby
	if dedicated_server and player_info.size() < 2:
		all_players_ready = false
	if all_players_ready:
		rpc_start_game()

func rpc_assign_player_to_affiliation(player:Player, affiliation:Affiliation) -> void:
	# Pass the paths to the player and affiliation, references don't make sense across peers
	var player_path:String = player.get_path()
	var affiliation_path:String = affiliation.get_path()
	assign_player_to_affiliation(player_path, affiliation_path)
	rpc("assign_player_to_affiliation", player_path, affiliation_path)

remote func assign_player_to_affiliation(player_path:String, affiliation_path:String) -> void:
	# Get the nodes from the paths
	var player:Player = get_node(player_path)
	var affiliation:Affiliation = get_node(affiliation_path)

	if player.is_inside_tree():
		player.get_parent().remove_child(player)

	# Remove this player from the affiliation its current one
	if player.affiliation:
		player.affiliation.players.erase(player)

	# Add the player to the specified affiliation
	affiliation.assign_player(player)
	affiliation.add_child(player)
	player.affiliation = affiliation
	emit_signal("lobby_ui_update")

# Return the player node associated with a network peer ID
func get_player(id:int) -> Player:
	return player_info[id]

# Add a player on all peers, including this one, returning a reference to the local player
func rpc_add_player(peer_id:int, affiliation:Affiliation, id:String) -> Player:
	# Use paths to get nodes across all peers, can't pass references through RPC
	var affiliation_path:String = affiliation.get_path()

	rpc("add_player", peer_id, affiliation_path, id, true)
	return add_player(peer_id, affiliation_path, id, true)

# Instance a player scene, map the network peer ID to it, and return it
# Doesn't contain a 'name' argument because the unique peer ID is appended to the name, so it's consistent
# If 'use_start_ui_id' is set it will set the id from the variable gathered from the start screen earlier
remote func add_player(peer_id:int, affiliation_path:String, new_id:String, use_start_ui_id:bool) -> Player:
#	print("Add Player with ID ", id, " for ", peer_id, " to affiliation ID ", affiliation.id)

	# Instance the player and set its information
	var player_scene = load("res://Player.tscn")
	var player_node:Player = player_scene.instance()
	player_node.set_name("Player" + str(peer_id))
	player_node.set_network_master(peer_id)
	player_node.id = new_id

	if not use_start_ui_id:
		player_node.id = new_id

	add_child(player_node) # Player needs to be part of the tree to have a path
	assign_player_to_affiliation(player_node.get_path(), affiliation_path)

	player_info[peer_id] = player_node
	assert(player_node.connect("ready_to_start", self, "check_game_start_lobby") == 0)

	# If we're the owner of the player set its ID on all peers
	if use_start_ui_id and get_tree().get_network_unique_id() == peer_id:
		player_node.rpc_set_id(player_name_from_title)

	emit_signal("lobby_ui_update")
	return player_node

# Adds a new affiliation node with the same name to all peers
func rpc_add_affiliation(color:Color, id:String) -> Affiliation:
	var new_affiliation_node:Affiliation = add_affiliation(color, id, "")
	rpc("add_affiliation", color, id, new_affiliation_node.get_name())
	return new_affiliation_node

# Adds an affiliation with a set name if it is supplied as a not-empty string
remote func add_affiliation(color:Color, id:String, name:String) -> Affiliation:
	var affiliation_scene = load("res://Affiliation.tscn")
	var affiliation_node:Affiliation = affiliation_scene.instance()
	affiliations.append(affiliation_node)
	affiliation_node.set_network_master(1)
	affiliation_node.id = id
	affiliation_node.color = color
	if name != "":
		affiliation_node.set_name(name)
	add_child(affiliation_node, true) # Add the affiliations as a child of Main

	emit_signal("lobby_ui_update")
	return affiliation_node

# Removes an affiliation on all peers
func rpc_remove_affiliation(affiliation:Affiliation) -> void:
	# Pass paths through RPC instead of references
	var affiliation_path:String = affiliation.get_path()
	remove_affiliation(affiliation_path)
	rpc("remove_affiliation", affiliation_path)

# Removes an affiliation if there is more than one, reassigning its players to another
remote func remove_affiliation(affiliation_path:String) -> void:
	# Get a reference to the affiliation from the path
	var affiliation:Affiliation = get_node(affiliation_path)

	# Ensure node is found and is an existing Affiliation
	if not affiliation:
		return
	if not affiliation is Affiliation:
		return
	if affiliations.size() == 1: # Do not allow deleting the last affiliation
		return

	# Find the affiliation in the list
	var i_to_delete:int = 0
	for i in range(affiliations.size()):
		if affiliations[i] == affiliation:
			i_to_delete = i # location of the affiliation to delete in list
			break

	var i_to_move_to:int = 1 if i_to_delete == 0 else i_to_delete - 1;

	var successor:Affiliation = affiliations[i_to_move_to]

	for player in affiliation.players:
		assign_player_to_affiliation(player.get_path(), successor.get_path())

	affiliations.erase(affiliation)
	affiliation.queue_free()

	emit_signal("lobby_ui_update")

# Remove a player from the global list and free it
remote func remove_player(peer_id:int) -> void:
	var player:Player = get_player(peer_id)
	if not player:
		print("ERROR (remove_player): No player found with peer id ", peer_id, "")
		return
	player.affiliation.players.erase(player)
	player.queue_free()
	player_info[peer_id] = null

	emit_signal("lobby_ui_update")

remote func server_unlock_peer_multiplayer():
	# TODO: Use a more complex lock, indluding tracking which player is locked, handle timing out etc...
	multiplayer_lock += 1
	if multiplayer_lock == player_info.size():
		emit_signal("multiplayer_lock_complete")
		multiplayer_lock = 0
		# TODO: Disconnect all connections to signal
#		self.disconnect("multiplayer_lock_complete", ..., ...)

func multiplayer_unlock():
	rpc_id(1, "server_unlock_peer_multiplayer")

func rpc_start_game() -> void:
	start_game()
	rpc("start_game")

# Start the game scene with the terrain, freeing the lobby UI
remote func start_game():
	# Load game scene
	var game_scene = load("res://Game.tscn")
	var game_node = game_scene.instance()
	add_child(game_node, true)
	$LobbyUI.queue_free()

	# Add the game UI for the player
	get_player(get_tree().get_network_unique_id()).load_ui()

	game_node.start_game()
	game_started = true

	self.connect("multiplayer_lock_complete", game_node, "place_start_map_items")

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
	var affiliation:Affiliation = add_affiliation(Color(1, 0, 0), "Affiliation 1", "")

	# Add player and add it to the affiliation
	get_start_ui_player_name()
	var player:Player = add_player(1, affiliation.get_path(), "", true)

	# basin should automatically be ready when the server starts
	if dedicated_server:
		player.set_lobby_ready(true)

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
		peer.close_connection()
		join_game()
	elif error == ERR_CANT_CREATE:
		print("Can't create connection")

func rpc_update_lobby_ui() -> void:
	rpc("update_lobby_ui")

remote func update_lobby_ui() -> void:
	emit_signal("lobby_ui_update")

func network_peer_connected(new_peer_id):
	if not get_tree().is_network_server():
		return
	# Set up the current tree for a newly joined player
#		print("  Giving new peer existing tree")
	for child in get_children():
		if child is Affiliation:
			# Add each affiliation to the new peer
			var affiliation = child as Affiliation
#				print("    Adding affiliation (ID: " + affiliation.id + ")")
			rpc_id(new_peer_id, "add_affiliation", affiliation.color, affiliation.id, affiliation.get_name())

			# Add that affiliation's players
			for aff_child in affiliation.get_children():
				if aff_child is Player:
					var player = aff_child as Player
#						print("    Adding player (ID:", player.id, ", Affiliation: ", player.affiliation.get_name(), ")")
					rpc_id(new_peer_id, "add_player", player.get_network_master(), player.affiliation.get_path(), player.id, false)

	# Add a new affiliation and player to the newly joined peer
	var new_affiliation:Affiliation = rpc_add_affiliation(Color(randf(), randf(), randf()), "New Affiliation")
	# warning-ignore:return_value_discarded
	rpc_add_player(new_peer_id, new_affiliation, "TEMP ID")

func network_peer_disconnected(id):
	# Get a unique affiliation name from the server
	if get_tree().is_network_server():
		remove_player(id)
		rpc("remove_player", id)

func connected_to_server():
	connected_success = true
	pass

func connection_failed():
	pass

func server_disconnected():
	get_tree().quit()

func cmd_args_exist() -> bool:
	# command line args will only exist if
	# basin is running this program
	return OS.get_cmdline_args().size() > 0
