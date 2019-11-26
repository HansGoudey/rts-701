extends Spatial

# Navigation Node (For intersecting with terrain)
var navigation:Navigation = null
var navmesh_id:int = 0
var navigation_mesh:NavigationMesh = null

# 2D Navigation Node (For unit pathfinding)
var navigation_2d:Navigation2D = null
var navpoly_id:int = 0
var navigation_polygon:NavigationPolygon = null

# Resource Generation
const MAX_MAP_HEIGHT:float = 1000.0 # For intersections with terrain
enum {RESOURCE0 = 0, RESOURCE1 = 1, RESOURCE2 = 2}
var num_of_resources:int = 10
var rng:RandomNumberGenerator = null

func _ready():
	# Add the terrain
	var terrain_file = preload("res://Map/SimpleTerrain.glb")
	var terrain_node = terrain_file.instance()
	add_child(terrain_node)
	var terrain_mesh_instance:MeshInstance = terrain_node.get_child(0)
	var terrain_mesh:Mesh = terrain_mesh_instance.get_mesh()

	# Initiate 3D navigation information
	navigation = $Navigation
	var navigation_mesh_instance:NavigationMeshInstance = NavigationMeshInstance.new()
	navigation_mesh = NavigationMesh.new()
	navigation_mesh.create_from_mesh(terrain_mesh)

	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
	navigation_mesh_instance.set_enabled(true)
	navigation.add_child(navigation_mesh_instance)

	# Initiate the 2D navigation node for unit navigation
	navigation_2d = $Navigation2D
	navigation_polygon = NavigationPolygon.new()
	var terrain_aabb:AABB = terrain_mesh_instance.get_transformed_aabb()
	var outline:PoolVector2Array = PoolVector2Array()
	# Add the four corners of the terrain to the polygon
	outline.push_back(Vector2(terrain_aabb.position.x, terrain_aabb.position.z))
	outline.push_back(Vector2(terrain_aabb.end.x, terrain_aabb.position.z))
	outline.push_back(Vector2(terrain_aabb.end.x, terrain_aabb.end.z))
	outline.push_back(Vector2(terrain_aabb.position.x, terrain_aabb.end.z))
	print("Outline:")
	print(outline[0].x, ", ", outline[0].y)
	print(outline[1].x, ", ", outline[1].y)
	print(outline[2].x, ", ", outline[2].y)
	print(outline[3].x, ", ", outline[3].y)
	navigation_polygon.add_outline(outline)
	navigation_polygon.make_polygons_from_outlines()

	var navigation_polygon_instance:NavigationPolygonInstance = NavigationPolygonInstance.new()
	navigation_polygon_instance.navpoly = navigation_polygon

	navigation_2d.navpoly_add(navigation_polygon, Transform2D.IDENTITY)
	navigation_polygon_instance.set_enabled(true)
	navigation_2d.add_child(navigation_polygon_instance)


	if get_tree().is_network_server(): # Only the server should find the random locations
		rng = RandomNumberGenerator.new()
		randomly_place_resources()

# Adds the resource of the specified type with a consistent name across peers
func rpc_add_resource(type:int, x:float, z:float) -> void:
	var position:Vector3 = navigation.get_closest_point_to_segment(Vector3(x, 0, z), Vector3(x, MAX_MAP_HEIGHT, z))
	var new_resource_name:String = add_resource(type, position).get_name()
	rpc("add_resource", type, position, new_resource_name)

remote func add_resource(type:int, position:Vector3, name:String = ""): # Return would be typed but cyclic dependency error
	var resource_scene = preload("res://Resources/Resource.tscn")
	var resource_node = resource_scene.instance()
	resource_node.load_resource(type)
	resource_node.translate(position)
	if name != "":
		resource_node.set_name(name)
	add_child(resource_node, true)

	return resource_node

func randomly_place_resources():
	var navigation_node:Navigation = get_node("/root/Main/Game/Map/Navigation")
	var main_node = get_node("/root/Main")
	var affiliations = main_node.affiliations
	var player_count = 0
	for affiliation in affiliations:
		player_count += 1
	var theta = 360/player_count
	var right_ray = 360/player_count
	var left_ray = 0
	for i in range(player_count):
		# warning-ignore:unused_variable
		for j in range(num_of_resources):
			var r = rng.randi_range(0, 50)
			var th = rng.randi_range(left_ray, right_ray)
			var coords = polar2cartesian(r, th)
			left_ray += theta
			right_ray += theta
			rpc_add_resource(RESOURCE1, coords[0], coords[1])
