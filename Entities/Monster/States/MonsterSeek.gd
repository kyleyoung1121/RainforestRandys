extends State
class_name MonsterSeek


@export var idle_state: State
@export var roam_state: State
@export var chase_state: State
@export var stalk_state: State


func enter():
	if not parent:
		return
	
	choose_seek_destination()
	
	# Choose random timing for when to switch to new state
	var random_delay = randf_range(parent.DECISION_TIMER_DELAY[0], parent.DECISION_TIMER_DELAY[1])
	parent.decision_timer.timeout.connect(change_behavior)
	parent.decision_timer.start(random_delay)


func exit():
	parent.decision_timer.timeout.disconnect(change_behavior)
	parent.decision_timer.stop()


func physics_update(delta):
	if parent:
		# if the monster reaches the location, choose new behavior
		if parent.navigation.is_navigation_finished():
			choose_seek_destination()
		var next_path_position = parent.navigation.get_next_path_position()
		var new_velocity = (next_path_position - parent.position).normalized()
		new_velocity *= parent.SPEED * parent.SLOW_SPEED_MULTIPLIER
		parent.velocity = parent.velocity.lerp(new_velocity, 1.0 - exp(-parent.ACCELERATION * delta))


func choose_seek_destination():
	# Keep choosing positions, until one is reachable
	while true:
		# Find nearest player, we should choose a position near them.
		var nearest_player = parent.find_nearest_player()
		var distance_from_player = parent.position.distance_to(nearest_player)
		# Have the monster move somewhere around halfway to the player
		var seek_range = distance_from_player / 2
		# The minimum should be half its sight range, so it doesnt path directly onto the player
		if seek_range < parent.SIGHT/2:
			seek_range = parent.SIGHT/2
		
		# We want to choose a new point in any direction (0 - 2pi) from the players perspective
		var phi = randf_range(0, PI * 2)
		var radius = seek_range
		
		# Based on the polar coords: rotation (phi) and radius, calculate the new x and z
		var new_x = radius * cos(phi)
		var new_z = radius * sin(phi)
		
		# Update the roam destination, ignoring the vertical axis.
		parent.navigation.target_position = nearest_player + Vector3(new_x, 0, new_z)
		
		# We are only done if this new location is pathable.
		if parent.navigation.is_target_reachable() or true:
			break


func on_player_spotted():
	transitioned.emit(self, stalk_state)


func change_behavior():
	var rand_choice = randf()
	
	# 20% - Stay in SEEK State
	if rand_choice <= 0.2:
		var random_delay = randf_range(parent.DECISION_TIMER_DELAY[0], parent.DECISION_TIMER_DELAY[1])
		parent.decision_timer.start(random_delay)
	
	# 40% - Go to IDLE State
	elif rand_choice <= 0.6:
		transitioned.emit(self, idle_state)
	
	# 40% - Go to ROAM State
	else:
		transitioned.emit(self, roam_state)
