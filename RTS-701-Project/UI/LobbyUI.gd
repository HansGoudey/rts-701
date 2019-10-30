extends Control

var main:Main = null
var last_ui_build = [] # For clearing the last set of panels built

func _ready():
	# Connect signals from updating affiliations and players to UI update function
	main = find_parent("Main")
	assert(main.connect("lobby_ui_update", self, "build_ui") == OK)
	
	# Connect signals from the UI to the main scene
	assert($NewAffiliation.connect("pressed", main, "add_affiliation", 
									[Color(randf(), randf(), randf()), "New Affiliation"]) == OK)
	
	# Theming
	$AffiliationItem.add_color_override("Theme", Color(0.5, 0.5, 0.5, 0.75))
	
	# These panels serve as templates for the player / affiliation UI, so hide them
	$AffiliationItem.visible = false
	$PlayerItem.visible = false
	
	build_ui()

func set_color_rect_from_hue(hue:float, color_rect:ColorRect) -> void:
	var color:Color = Color.from_hsv(hue, 0.75, 1)
	color_rect.color = color

# Builds the entire lobby UI. Called whenever there is an update to affiliation / player structure
# TODO: Lobby UI should really be built by keeping the ui elements for affiliations around with them rather
#       than rebuilding it every time, so it would stay more consistent during editing, but this isn't 
#       high priority
func build_ui() -> void:
	var screen_height:float = get_viewport().size.y
	var y:float = screen_height * 0.05
	
	# Don't try to draw the UI if we haven't connected to the server yet
	if not get_tree().is_network_server() and not main.connected_success:
		return

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
		
		var color_slider:HSlider = color_rect.get_child(0) # TODO: Only show slider when color_rect is clicked
		color_slider.value = affiliation.color.h
		assert(color_slider.connect("value_changed", affiliation, "set_color_from_hue") == OK)
		assert(color_slider.connect("value_changed", self, "set_color_rect_from_hue", [color_rect]) == OK)
		
		var join_button:Button = new_affiliation_item.get_child(2)
		assert(join_button.connect("pressed", main, "rpc_assign_player_to_affiliation", 
									[main.get_player(get_tree().get_network_unique_id()), affiliation]) == OK)
									
		var delete_button:Button = new_affiliation_item.get_child(3)
		assert(delete_button.connect("pressed", main, "rpc_remove_affiliation", [affiliation]) == OK)
		
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
