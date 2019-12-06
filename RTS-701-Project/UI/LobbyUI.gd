extends Control

var main:Main = null
var map_selector:ItemList
var last_ui_build = [] # For clearing the last set of panels built

func _ready() -> void:
	# Connect signals from updating affiliations and players to UI update function
	main = find_parent("Main")
	assert(main.connect("lobby_ui_update", self, "build_ui") == OK)

	# Connect signals from the UI to the main scene
	assert($NewAffiliation.connect("pressed", main, "rpc_add_affiliation",
									[Color(randf(), randf(), randf()), "New Affiliation"]) == OK)

	# Theming
	$AffiliationItem.add_color_override("Theme", Color(0.5, 0.5, 0.5, 0.75))

	# These panels serve as templates for the player / affiliation UI, so hide them
	$AffiliationItem.visible = false
	$PlayerItem.visible = false

	# Set up the map selector's items, signals, and default
	var map_selector = $MapSelector/ItemList
	map_selector.add_item("Terrain")
	map_selector.add_item("SimpleTerrain")
	map_selector.select(1)
	map_selector.connect("item_selected", self, "rpc_push_map_selection")

	build_ui()

func rpc_push_map_selection() -> void:
	var selection:int = map_selector.get_selected_items()[0]

remote func select_map(selection:int) -> void:
	map_selector.select(selection)

# Builds the entire lobby UI. Called whenever there is an update to affiliation / player structure
# TODO: Lobby UI should really be built by keeping the ui elements for affiliations around with them rather
#       than rebuilding it every time, so it would stay more consistent during editing, but this isn't
#       high priority
# TODO: Break this up into smaller functions
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
		assert(affiliation.connect("color_updated", color_rect, "set_frame_color") == OK)

		var color_slider:HSlider = color_rect.get_child(0) # TODO: Only show slider when color_rect is clicked
		color_slider.value = affiliation.color.h
		assert(color_slider.connect("value_changed", affiliation, "rpc_set_color_from_hue") == OK)

		var join_button:Button = new_affiliation_item.get_child(2)
		if get_tree().get_network_unique_id() in main.player_info.keys(): # Maybe player isn't added yet
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
			if player.is_network_master():
				assert(ready_button.connect("toggled", player, "rpc_set_lobby_ready") == OK)
			else:
				# Show status indicator for other players instead of a checkbox
				ready_button.set_visible(false)
				var ready_indicator:ColorRect = ColorRect.new()
				ready_indicator.rect_position = ready_button.rect_position
				ready_indicator.rect_size = ready_button.rect_size
				if player.ready_to_start:
					ready_indicator.color = Color.green
				else:
					ready_indicator.color = Color.red # TODO: Bad for colorblindness?

				new_player_item.add_child(ready_indicator)
			# All subsequent elements are further down, and the affiliation box expands
			y += new_player_item.rect_size.y
			new_affiliation_item.rect_size.y += new_player_item.rect_size.y

		# Add some blank space in between affiliations
		y += screen_height * 0.02
