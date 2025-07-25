extends State
class_name MonsterIdle


@export var roam_state: State
@export var seek_state: State
@export var chase_state: State
@export var stalk_state: State

# This state should have a shorter duration, since it's not interesting to have the monster stand still
const DECISION_TIMER_MODIFIER := 0.25

var nearby_players: Array[Player]
var try_scanning_players := false


func enter():
	# Choose random timing for when to switch to new state
	var random_delay = randf_range(parent.DECISION_TIMER_DELAY[0], parent.DECISION_TIMER_DELAY[1])
	random_delay *= DECISION_TIMER_MODIFIER
	parent.decision_timer.timeout.connect(change_behavior)
	parent.decision_timer.start(random_delay)


func exit():
	parent.decision_timer.timeout.disconnect(change_behavior)
	parent.decision_timer.stop()


func physics_update(delta):
	if parent:
		parent.velocity = parent.velocity.lerp(Vector3(), parent.ACCELERATION * delta)


func on_player_spotted():
	transitioned.emit(self, stalk_state)


func change_behavior():
	var rand_choice = randf()
	
	# 20% - Stay in IDLE State
	if rand_choice <= 0.2: #0.2:
		var random_delay = randf_range(parent.DECISION_TIMER_DELAY[0], parent.DECISION_TIMER_DELAY[1])
		parent.decision_timer.start(random_delay)
	
	# 40% - Go to ROAM State
	elif rand_choice <= 0.6:
		transitioned.emit(self, roam_state)
	
	# 40% - Go to SEEK State
	else:
		transitioned.emit(self, seek_state)
