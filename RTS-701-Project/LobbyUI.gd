extends Control

var main:Main = null

func _ready():
	# Connect signals from updating affiliations and players to UI update function
	main = find_parent("Main")
	main.connect("add_player", self, "build_ui")
	main.connect("add_affiliation", self, "build_ui")
	
	$AffiliationItem.add_color_override("Theme", Color(0.5, 0.5, 0.5, 0.75))
	$AffiliationItem.visible = false
	$PlayerItem.visible = false
	
	build_ui()

# Builds the entire lobby UI. Called whenever there is an update to affiliation / player structure
func build_ui() -> void:
	var screen_height:int = get_viewport().size.y
	var y:int = screen_height * 0.05
	
	# Delete all of the UI elements from the last time it was drawn
	for child in get_children():
		if child.is_visible(): # The original items are invisible
			child.queue_free()
	
	# Add all of affiliations
	var new_affiliation_item:Panel = null
	var new_player_item:Panel = null
	for affiliation in main.affiliations:
		assert(affiliation is Affiliation)
		new_affiliation_item = $AffiliationItem.duplicate(0)
		new_affiliation_item.rect_position.y = y
		new_affiliation_item.set_visible(true)
		add_child(new_affiliation_item)
		
		# Match UI to the this affiliation's values
		var label:Label = new_affiliation_item.get_child(0)
		label.text = affiliation.id
		var color_rect:ColorRect = new_affiliation_item.get_child(1)
		color_rect.color = affiliation.color
		
		# Add subsequent elements are further down
		y += new_affiliation_item.rect_size.y
		
		# Add the players for each affiliation
		for player in affiliation.players:
			assert(player is Player)
			new_player_item = $PlayerItem.duplicate(0)
			new_player_item.rect_position.y = y
			new_player_item.set_visible(true)
			add_child(new_player_item)
			
			# Match UI to this player's values
			label = new_player_item.get_child(0)
			label.text = player.id
			
			# All subsequent elements are further down, and the affiliation box expands
			y += new_player_item.rect_size.y
			new_affiliation_item.rect_size.y += new_player_item.rect_size.y
		
		# Add some blank space in between affiliations
		y += screen_height * 0.05