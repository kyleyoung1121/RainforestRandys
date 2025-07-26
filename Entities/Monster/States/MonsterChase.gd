extends State
class_name MonsterChase

@export var seek_state: State

var abandon_chase_timer: Timer
var timer_running = false


func _ready():
	abandon_chase_timer = Timer.new()
	abandon_chase_timer.one_shot = true
	abandon_chase_timer.timeout.connect(abandon_chase)
	add_child(abandon_chase_timer)


func physics_update(delta):
	if not parent:
		return
	
	# If there are visible players, chase the nearest one
	if parent.players_seen.size() != 0:
		parent.navigation.target_position = parent.find_nearest_player(true)
		var next_path_position = parent.navigation.get_next_path_position()
		var new_velocity = (next_path_position - parent.position).normalized() * parent.SPEED
		parent.velocity = parent.velocity.lerp(new_velocity, 1.0 - exp(-parent.ACCELERATION * delta))
	
	# When line of sight is lost, path to the last known location
	else:
		parent.navigation.target_position = parent.player_last_seen_at
		var next_path_position = parent.navigation.get_next_path_position()
		var new_velocity = (next_path_position - parent.position).normalized() * parent.SPEED
		parent.velocity = parent.velocity.lerp(new_velocity, 1.0 - exp(-parent.ACCELERATION * delta))
		
		# If line of sight is not regained when arriving at the last known location, change to SEEK
		if parent.navigation.is_navigation_finished():
			if not timer_running:
				timer_running = true
				abandon_chase_timer.start(0.5)


func abandon_chase():
	abandon_chase_timer.stop()
	timer_running = false
	
	# One last check to see if the chase may continue
	if parent.players_seen.size() != 0 or not parent.navigation.is_navigation_finished():
		return
	
	transitioned.emit(self, seek_state)
