extends CharacterBody3D


const SPEED := 3.0
const ACCELERATION := 2.5
const SLOW_SPEED_MULTIPLIER := 0.6
const SIGHT := 13.0
const DECISION_TIMER_DELAY := [5, 15]
const DETECTION_TIME := 2.5

@onready var navigation := $NavigationAgent3D
@onready var decision_timer := $DecisionTimer
@onready var detection_timer = $DetectionTimer
@onready var player_scan_timer = $PlayerScanTimer
@onready var sight = $Sight
@onready var sight_collision := $Sight/CollisionShape3D
@onready var line_of_sight_ray = $LineOfSightRay
@onready var state_machine = $StateMachine

var nearby_players: Array[Player]
var players_seen: Array[Player]
var try_scanning_players := false
var player_last_seen_at: Vector3


func _ready():
	sight_collision.shape.radius = SIGHT
	state_machine.init(self)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if try_scanning_players and nearby_players.size() != 0:
		line_of_sight_ray.target_position = nearby_players[0].global_position - global_position


func find_nearest_player(only_visible_players = false):
	# Fetch all players & get their positions.
	var players
	if only_visible_players:
		players = players_seen
	else:
		players = get_tree().get_nodes_in_group("Player")
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


func _on_sight_body_entered(body):
	if body is Player:
		# Track all players in range
		if not body in nearby_players:
			nearby_players.append(body)
		try_scanning_players = true
		player_scan_timer.start()
		scan_for_players()
	
	# Also notify all states in case they have extra steps to take
	state_machine.on_sight_body_entered()


func _on_sight_body_exited(body):
	if body is Player:
		# Stop tracking this player
		if body in nearby_players:
			nearby_players.erase(body)
		if body in players_seen:
			players_seen.erase(body)
		if nearby_players.size() <= 0:
			try_scanning_players = false
			player_last_seen_at = body.position
	
	# Also notify all states in case they have extra steps to take
	state_machine.on_sight_body_exited()


func scan_for_players():
	if not try_scanning_players or nearby_players.size() == 0:
		player_scan_timer.stop()
		return
	
	# For any nearby players, cast a ray to see if there is line of sight
	for player in nearby_players:
		# If raycast is successful, player is seen
		if line_of_sight_ray.get_collider() is Player:
			if not player in players_seen:
				players_seen.append(player)
			state_machine.on_player_spotted()
		
		# If player was previously seen and is not anymore, remove from players_seen
		elif player in players_seen:
			players_seen.erase(player)
			state_machine.on_player_lost()
			player_last_seen_at = player.position
	
	# If no line of sight is found, check again after a short delay
