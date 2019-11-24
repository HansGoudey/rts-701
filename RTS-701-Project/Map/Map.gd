extends Spatial

# Navigation Node (For intersecting with terrain)
var navigation:Navigation = null
var navmesh_id:int = 0
var navigation_mesh:NavigationMesh = null # Shared with all units

# Resource Generation
const MAX_MAP_HEIGHT:float = 1000.0 # For intersections with terrain
enum {RESOURCE0 = 0, RESOURCE1 = 1, RESOURCE2 = 2}
var num_of_resources:int = 10
var rng:RandomNumberGenerator

func _ready():
	# Add the terrain
	var terrain_file = preload("res://Map/SimpleTerrain.glb")
	var terrain_node = terrain_file.instance()
	add_child(terrain_node)
#	var terrain_mesh_instance:MeshInstance = terrain_node.get_child(0)
#	var terrain_mesh:Mesh = terrain_mesh_instance.get_mesh()
#
#	# Initiate navigation information
	navigation = $Navigation
#	var navigation_mesh_instance:NavigationMeshInstance = NavigationMeshInstance.new()
#	navigation_mesh = NavigationMesh.new()
#	navigation_mesh.create_from_mesh(terrain_mesh)
#
#	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
#	navigation_mesh_instance.set_enabled(true)
#	navigation.add_child(navigation_mesh_instance)

	if get_tree().is_network_server(): # The server should find the random locations
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
# warning-ignore:unused_variable
	for i in range(num_of_resources):
		var x = rng.randi_range(-45, 45)
		var z = rng.randi_range(-45, 45)
		rpc_add_resource(RESOURCE1, x, z)
