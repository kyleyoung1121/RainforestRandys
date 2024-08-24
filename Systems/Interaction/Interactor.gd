class_name Interactor
extends Area3D

var controller: Node3D


func interact(interactable: Interactable) -> void:
	interactable.interacted.emit(self)


func focus(interactable: Interactable) -> void:
	interactable.focused.emit(self)


func unfocus(interactable: Interactable) -> void:
	interactable.unfocused.emit(self)


# Consider all interactable objects within range and get the closest one
func get_closest_interactable() -> Interactable:
	var nearby_interactables: Array[Area3D] = get_overlapping_areas()
	var distance: float
	var closest_distance: float = INF
	var closest: Interactable = null
	
	for interactable in nearby_interactables:
		if interactable.has_meta("is_collected") and interactable.get("is_collected"):
			continue # Skip this item if it's already collected
		
		distance = interactable.global_position.distance_to(global_position)
		
		if distance < closest_distance:
			closest = interactable as Interactable
			closest_distance = distance
	
	return closest
