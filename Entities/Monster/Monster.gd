extends CharacterBody3D


const SPEED := 3.0
const ACCELERATION := 5.0
const SLOW_SPEED_MULTIPLIER := 0.4
const SIGHT := 10.0
const DECISION_TIMER_DELAY := [5, 15]
const PROXIMITY_CLOSE = 0.15

@onready var navigation := $NavigationAgent3D
@onready var decision_timer := $DecisionTimer
@onready var sight_collision := $Sight/CollisionShape3D

enum States {
	IDLE,
	ROAMING,
	SEEKING,
	STALKING,
	CHASING,
}

var behavior := States.IDLE


func _ready():
	sight_collision.shape.radius = SIGHT
	choose_seek_destination()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if behavior == States.IDLE:
		velocity = velocity.lerp(Vector3(), ACCELERATION * delta)
	
	elif behavior == States.ROAMING:
		# if the monster reaches the location, choose new behavior
		if navigation.is_navigation_finished():
			choose_roam_destination()
		var next_path_position = navigation.get_next_path_position()
		var new_velocity = (next_path_position - position).normalized() * SPEED * SLOW_SPEED_MULTIPLIER
		velocity = velocity.lerp(new_velocity, ACCELERATION * delta)
	
	elif behavior == States.SEEKING:
		# if the monster reaches the location, choose new behavior
		if navigation.is_navigation_finished():
			choose_seek_destination()
		var next_path_position = navigation.get_next_path_position()
		var new_velocity = (next_path_position - position).normalized() * SPEED * SLOW_SPEED_MULTIPLIER
		velocity = velocity.lerp(new_velocity, ACCELERATION * delta)
	
	# During a chase, move towards the nearest player.
	elif behavior == States.CHASING:
		navigation.target_position = find_nearest_player()
		var next_path_position = navigation.get_next_path_position()
		var new_velocity = (next_path_position - position).normalized() * SPEED
		velocity = velocity.lerp(new_velocity, ACCELERATION * delta)
	
	move_and_slide()


func find_nearest_player():
	# Fetch all players & get their positions.
	var players = get_tree().get_nodes_in_group("Player")
	var player_positions = []
	for player in players:
		player_positions.append(player.position)
	
	# Find the nearest player. Skip sorting if there is only one.
	if not player_positions:
		push_error("Monster Navigation: No player found")
	elif len(player_positions) == 1:
		return player_positions[0]
	else:
		player_positions.sort_custom(func(a,b): return position.distance_to(a) < position.distance_to(b))
		return player_positions[0]


func choose_roam_destination():
	# Keep choosing positions, until one is reachable
	while true:
		# We want to choose a new point in any direction (0 - 2pi)
		var phi = randf_range(0, PI * 2)
		# The new point should be within sight, but not closer than 1/2 of sight range
		var radius = randf_range(SIGHT/2, SIGHT)
		
		# Based on the polar coords: rotation (phi) and radius, calculate the new x and z
		var new_x = radius * cos(phi)
		var new_z = radius * sin(phi)
		
		# Update the roam destination, ignoring the vertical axis.
		navigation.target_position = position + Vector3(new_x, 0, new_z)
		
		# We are only done if this new location is pathable.
		if navigation.is_target_reachable() or true:
			break


func choose_seek_destination():
	# Keep choosing positions, until one is reachable
	while true:
		# Find nearest player, we should choose a position near them.
		var nearest_player = find_nearest_player()
		var distance_from_player = position.distance_to(nearest_player)
		# Have the monster move somewhere around halfway to the player
		var seek_range = distance_from_player / 2
		# The minimum should be half its sight range, so it doesnt path directly onto the player
		if seek_range < SIGHT/2:
			seek_range = SIGHT/2
		
		# We want to choose a new point in any direction (0 - 2pi) from the players perspective
		var phi = randf_range(0, PI * 2)
		var radius = seek_range
		
		# Based on the polar coords: rotation (phi) and radius, calculate the new x and z
		var new_x = radius * cos(phi)
		var new_z = radius * sin(phi)
		
		# Update the roam destination, ignoring the vertical axis.
		navigation.target_position = nearest_player + Vector3(new_x, 0, new_z)
		
		# We are only done if this new location is pathable.
		if navigation.is_target_reachable() or true:
			break


func change_behavior():
	# Don't randomly stop chase
	if behavior == States.CHASING:
		pass
	
	else:
		var random_choice = randi_range(0,2)
		if random_choice == 0:
			print("Monster IDLE")
			behavior = States.IDLE
		elif random_choice == 1:
			print("Monster ROAMING")
			behavior = States.ROAMING
			choose_roam_destination()
		elif random_choice == 2:
			print("Monster SEEKING")
			behavior = States.SEEKING
			choose_seek_destination()
	
	var new_delay = randf_range(DECISION_TIMER_DELAY[0], DECISION_TIMER_DELAY[1])
	decision_timer.wait_time = new_delay
	decision_timer.start()
