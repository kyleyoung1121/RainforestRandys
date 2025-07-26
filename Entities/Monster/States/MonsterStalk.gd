extends State
class_name MonsterStalk


@export var seek_state: State
@export var chase_state: State


func enter():
	parent.detection_timer.timeout.connect(start_chase)
	parent.detection_timer.start(parent.DETECTION_TIME)


func exit():
	parent.detection_timer.stop()
	parent.detection_timer.timeout.disconnect(start_chase)


func physics_update(delta):
	if parent:
		parent.velocity = parent.velocity.lerp(Vector3(), 1.0 - exp(-parent.ACCELERATION * delta))


func on_player_lost():
	transitioned.emit(self, seek_state)


func start_chase():
	transitioned.emit(self, chase_state)
