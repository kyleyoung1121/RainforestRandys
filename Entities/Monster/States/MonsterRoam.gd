extends State
class_name MonsterRoam


@export var idle_state: State
@export var seek_state: State
@export var chase_state: State
@export var stalk_state: State


func enter():
	if not parent:
		return
	
	choose_roam_destination()
	
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
			choose_roam_destination()
		var next_path_position = parent.navigation.get_next_path_position()
		var new_velocity = (next_path_position - parent.position).normalized()
		new_velocity *= parent.SPEED * parent.SLOW_SPEED_MULTIPLIER
		parent.velocity = parent.velocity.lerp(new_velocity, parent.ACCELERATION * delta)


func choose_roam_destination():
	# Keep choosing positions, until one is reachable
	while true:
		# We want to choose a new point in any direction (0 - 2pi)
		var phi = randf_range(0, PI * 2)
		# The new point should be within sight, but not closer than 1/2 of sight range
		var radius = randf_range(parent.SIGHT/2, parent.SIGHT)
		
		# Based on the polar coords: rotation (phi) and radius, calculate the new x and z
		var new_x = radius * cos(phi)
		var new_z = radius * sin(phi)
		
		# Update the roam destination, ignoring the vertical axis.
		if parent.navigation:
			parent.navigation.target_position = parent.position + Vector3(new_x, 0, new_z)
		
			# We are only done if this new location is pathable.
			if parent.navigation.is_target_reachable() or true:
				break


func on_player_spotted():
	transitioned.emit(self, stalk_state)


func change_behavior():
	var rand_choice = randf()
	
	# 20% - Stay in ROAM State
	if rand_choice <= 0.2:
		var random_delay = randf_range(parent.DECISION_TIMER_DELAY[0], parent.DECISION_TIMER_DELAY[1])
		parent.decision_timer.start(random_delay)
	
	# 40% - Go to IDLE State
	elif rand_choice <= 0.6:
		transitioned.emit(self, idle_state)
	
	# 40% - Go to SEEK State
	else:
		transitioned.emit(self, seek_state)
