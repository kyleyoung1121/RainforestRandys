extends CharacterBody3D


const SPEED = 3.0
const DECISION_TIMER_DELAY = [5, 15]

@onready var navigation = $NavigationAgent3D
@onready var decision_timer = $DecisionTimer

enum States {
	IDLE,
	ROAMING,
	SEEKING,
	STALKING,
	CHASING,
}

var behavior = States.CHASING


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# During a chase, move towards the nearest player.
	if behavior == States.CHASING:
		navigation.target_position = find_nearest_player()
		var next_location = navigation.get_next_path_position()
		var current_location = global_transform.origin
		var new_velocity = (next_location - current_location).normalized() * SPEED
		velocity = velocity.move_toward(new_velocity, 0.25)
	
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


func change_behavior():
	# Don't randomly stop chase
	if behavior == States.CHASING:
		pass
	
	else:
		var random_choice = randi_range(0,2)
		if random_choice == 0:
			behavior = States.IDLE
		elif random_choice == 1:
			behavior = States.ROAMING
		elif random_choice == 2:
			behavior = States.SEEKING
	
	var new_delay = randf_range(DECISION_TIMER_DELAY[0], DECISION_TIMER_DELAY[1])
	decision_timer.wait_time = new_delay
	decision_timer.start()
