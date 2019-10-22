extends Control

var main:Main = null
var last_ui_build = [] # For clearing the last set of panels built

func _ready():
	# Connect signals from updating affiliations and players to UI update function
	main = find_parent("Main")
	assert(main.connect("add_player", self, "build_ui") == OK)
	assert(main.connect("add_affiliation", self, "build_ui") == OK)
	
	# Connect signals from the UI to the main scene
	assert($NewAffiliation.connect("pressed", main, "add_affiliation", 
									[Color(randf(), randf(), randf()), "New Affiliation"]) == OK)
	
	# Theming
	$AffiliationItem.add_color_override("Theme", Color(0.5, 0.5, 0.5, 0.75))
	
	# These panels serve as templates for the player / affiliation UI, so hide them
	$AffiliationItem.visible = false
	$PlayerItem.visible = false
	
	build_ui()

# Builds the entire lobby UI. Called whenever there is an update to affiliation / player structure
# TODO: Figure out how "connect" interacts with networking. The calls from the UI connections
#       should happen on all clients with RPC
func build_ui() -> void:
	var screen_height:float = get_viewport().size.y
	var y:float = screen_height * 0.05
	
	# Delete all of the UI elements from the last time it was drawn
	for panel in last_ui_build:
		panel.queue_free()
	last_ui_build.clear()
	
	# Add all of affiliations
	var new_affiliation_item:Panel = null
	var new_player_item:Panel = null
	for affiliation in main.affiliations:
		assert(affiliation is Affiliation)
		new_affiliation_item = $AffiliationItem.duplicate(0) # TODO: Instance these from scenes instead of duplicating
		new_affiliation_item.rect_position.y = y
		new_affiliation_item.set_visible(true)
		last_ui_build.append(new_affiliation_item)
		add_child(new_affiliation_item)
		
		# Match UI to the this affiliation's values
		var label:Label = new_affiliation_item.get_child(0)
		label.text = affiliation.id
		var color_rect:ColorRect = new_affiliation_item.get_child(1)
		color_rect.color = affiliation.color
		var join_button:Button = new_affiliation_item.get_child(2)
		# TODO: This connection might be a little hacky
		assert(join_button.connect("pressed", main, "assign_player_to_affiliation", 
									[main.get_player(get_tree().get_network_unique_id()), affiliation]) == OK)
		
		# Add subsequent elements are further down
		y += new_affiliation_item.rect_size.y
		
		# Add the players for each affiliation
		for player in affiliation.players:
			assert(player is Player)
			new_player_item = $PlayerItem.duplicate(0)
			new_player_item.rect_position.y = y
			new_player_item.set_visible(true)
			last_ui_build.append(new_player_item)
			add_child(new_player_item)
			
			# Match UI to this player's values
			label = new_player_item.get_child(0)
			label.text = player.id
			var ready_button:Button = new_player_item.get_child(1)
			assert(ready_button.connect("toggled", player, "set_lobby_ready") == OK)
			
			# All subsequent elements are further down, and the affiliation box expands
			y += new_player_item.rect_size.y
			new_affiliation_item.rect_size.y += new_player_item.rect_size.y
		
		# Add some blank space in between affiliations
		y += screen_height * 0.02
