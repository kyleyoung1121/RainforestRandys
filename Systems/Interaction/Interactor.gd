class_name Interactor
extends Area3D

signal item_collected

var controller: Node3D


func interact(interactable: Interactable) -> void:
	interactable.interacted.emit(self)
	item_collected.emit(interactable.item_name)


func focus(interactable: Interactable) -> void:
	interactable.focused.emit(self)


func unfocus(interactable: Interactable) -> void:
	interactable.unfocused.emit(self)


# Consider all interactable objects within range and get the closest one
func get_closest_interactable() -> Interactable:
	var nearby_areas: Array[Area3D] = get_overlapping_areas()
	var nearby_interactables: Array[Interactable]
	for area in nearby_areas:
		if area is Interactable:
			nearby_interactables.append(area)
	var reachable_interactables: Array[Interactable]
	for interactable in nearby_interactables:
		if is_interactable_reachable(interactable):
			reachable_interactables.append(interactable)
	
	# Return out if no items are found
	if reachable_interactables.size() == 0:
		return null
	
	# Simply return the item if only one is present
	elif reachable_interactables.size() == 1:
		return reachable_interactables[0]
	
	# If many items are present, try to find the closest one
	var distance: float
	var closest_distance: float = INF
	var closest: Interactable = null
	# Some controllers may be able to raycast to find where we are interacting
	var looking_at: Vector3
	if controller.has_method("get_player_sight_ray_cast"):
		var controller_sight_ray_cast: RayCast3D = controller.get_player_sight_ray_cast()
		if controller_sight_ray_cast and controller_sight_ray_cast.is_colliding():
			looking_at = controller_sight_ray_cast.get_collision_point()
	
	for interactable in reachable_interactables:
		# If the controller has the ability to raycast, check against where it is looking
		if looking_at:
			distance = interactable.global_position.distance_to(looking_at)
		# Otherwise, compare against the interacters position (less precise, but a fine fallback)
		else:
			distance = interactable.global_position.distance_to(global_position)
		
		if distance < closest_distance:
			closest = interactable
			closest_distance = distance
	
	return closest


func is_interactable_reachable(interactable: Interactable):
	if not is_instance_valid(interactable):
		return false
	
	if controller.has_method("get_player_sight_ray_cast"):
		var controller_sight_ray_cast: RayCast3D = controller.get_player_sight_ray_cast()
		if controller_sight_ray_cast and controller_sight_ray_cast.is_colliding():
			if controller_sight_ray_cast.get_collider() is Interactable:
				return true
	
	return false
