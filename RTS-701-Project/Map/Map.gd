extends Spatial

var navigation:Navigation = null
var navmesh_id:int = 0

func _ready():
	# Add the terrain
	var terrain_file = load("res://Map/SimpleTerrain.glb")
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
