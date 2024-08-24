extends Node3D

@onready var backup_spawn = $ItemSpawns/BackUpSpawn

var item_scene = preload("res://Props/Item.tscn")
var item_spawns = {}

var player

# Each item will be slightly repositioned & rotated
var item_position_variance = 0.06
var item_rotation_variance = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_nodes_in_group("Player"):
		player = get_tree().get_nodes_in_group("Player")[0]
	build_item_spawns_dictionary()
	populate_shelves()


func populate_shelves():
	# Add at least two of every item on the player's list
	for item in player.shopping_list:
		for i in range(randi_range(2,4)):
			place_item(item)
	
	# Add 0, 1, or 2 of each other item, to help fill the shelves
	for optional_item in get_optional_items():
		for i in range(randi_range(0,2)):
			place_item(optional_item)


func place_item(item):
	# Determine which department this item is in
	var item_department = ItemData.departments[item]
	
	# Find a spawn point
	var available_spawn_point
	
	# Option 1: spots are open in requested department
	if item_spawns.has(item_department) and item_spawns[item_department].size() > 0:
		available_spawn_point = item_spawns[item_department].pop_front()
		
	# Option 2: try to fill generic spots
	elif item_spawns.has('generic') and item_spawns['generic'].size() > 0:
		available_spawn_point = item_spawns['generic'].pop_front()
		
	# Option 3: as a last resort, spawn all other items at the back up location: lost & found
	else:
		available_spawn_point = backup_spawn
	
	# Look through the ListItems folder for a subfolder that matches the item
	var mesh_scene
	var mesh_folder = DirAccess.open("res://Props/Meshes/ListItems/")
	if mesh_folder:
		mesh_folder.list_dir_begin()
		var folder_item = mesh_folder.get_next()
		while folder_item != "":
			if mesh_folder.current_is_dir():
				# The mesh's scene should be in the directory of the same name
				if folder_item == item:
					var item_scene_path = "res://Props/Meshes/ListItems/" + folder_item + "/" + item + ".tscn"
					mesh_scene = load(item_scene_path)
					if mesh_scene:
						break
			folder_item = mesh_folder.get_next()
	
	# If we found the desired scene, build out a new item, and attach to the spawn point
	if mesh_scene:
		# Instantiate an item scene
		var item_instance = item_scene.instantiate()
		# Instantiate the mesh's scene
		var mesh_instance = mesh_scene.instantiate()
		# Attach the mesh to the item
		item_instance.add_child(mesh_instance)
		# Attach the item to the spawn point
		available_spawn_point.add_child(item_instance)
		
		# Slightly adjust transform
		item_instance.position.x += randf_range(-item_position_variance, item_position_variance)
		item_instance.position.z += randf_range(-item_position_variance, item_position_variance)
		item_instance.rotation.y += randf_range(-deg_to_rad(item_rotation_variance), deg_to_rad(item_rotation_variance))
		
		# DEBUG
		print("Item added! (" + item + ")" )


func get_optional_items():
	# Start with a copy of all items
	var optional_items = ItemData.departments.keys().duplicate()
	
	# Remove any items that also appear in the player's shopping list
	for mandatory_item in player.shopping_list:
		if mandatory_item in optional_items:
			optional_items.erase(mandatory_item)
	
	# Return the final list, containing only non-mandatory items
	return optional_items


func build_item_spawns_dictionary():
	# Get all item spawn points
	var all_spawns = get_tree().get_nodes_in_group("ItemSpawn")
	
	for item_spawn in all_spawns:
		# If the spawn point's department already has a list, add this spawn to it
		if item_spawns.has(item_spawn.department):
			item_spawns[item_spawn.department].push_back(item_spawn)
		# Otherwise, start a new list for this department
		else:
			item_spawns[item_spawn.department] = [item_spawn]
	
	# Shuffle each list of locations (to help randomize distribution)
	for department in item_spawns.keys():
		item_spawns[department].shuffle()
