extends Spatial

var navigation:Navigation = null
var navmesh_id:int = 0

var num_of_resources: int = 10
var rng = RandomNumberGenerator.new()

func _ready():
	# Add the terrain
	var terrain_file = preload("res://Map/SimpleTerrain.glb")
	var terrain_node = terrain_file.instance()
	add_child(terrain_node)
	var terrain_mesh_instance:MeshInstance = terrain_node.get_child(0)
	var terrain_mesh:Mesh = terrain_mesh_instance.get_mesh()

	# Initiate navigation information
	navigation = $Navigation
	var navigation_mesh_instance:NavigationMeshInstance = NavigationMeshInstance.new()
	var navigation_mesh:NavigationMesh = NavigationMesh.new()
	navigation_mesh.create_from_mesh(terrain_mesh)

	navmesh_id = navigation.navmesh_add(navigation_mesh, Transform.IDENTITY)
	navigation_mesh_instance.set_enabled(true)
	navigation.add_child(navigation_mesh_instance)
	
	randomly_place_resources()

func randomly_place_resources():
	var navigation_node:Navigation = get_node("/root/Main/Game/Map/Navigation")
	for i in range(num_of_resources):
		var x = rng.randi_range(-45, 45)
		var z = rng.randi_range(-45, 45)
		var location = navigation_node.get_closest_point_to_segment(Vector3(x,0,z), Vector3(x, 1000, z))
		var resource_scene = load("res://Resources/ResourceBasic.tscn")
		var resource_node = resource_scene.instance()
		resource_node.translate(location)
		add_child(resource_node)
		
