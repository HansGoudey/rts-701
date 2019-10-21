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

# Hacky way to do this.. just builds the UI again whenever there is an update
func build_ui():
	print("Build UI")
	print("Affiliations length:", str(main.affiliations.size()))
	var screen_height:int = get_viewport().size.y
	var y:int = screen_height * 0.05
	
	# Add all of affiliations
	var new_affiliation_item:Panel = null
	var new_player_item:Panel = null
	for affiliation in main.affiliations:
		print("Adding affiliation " + affiliation.id)
		new_affiliation_item = $AffiliationItem.duplicate(0)
		new_affiliation_item.rect_position.y = y
		new_affiliation_item.visible = true
		y += new_affiliation_item.rect_size.y
		
		# Add the players for each affiliation
		for player in affiliation.players:
			new_player_item = $PlayerItem.duplicate(0)
			new_player_item.rect_position.y = y
			new_player_item.visible = true
			y += new_player_item.rect_size.y
			new_affiliation_item.rect_size.y += new_player_item.rect_size.y
		
		y += screen_height * 0.05
		
	main.print_tree_pretty()