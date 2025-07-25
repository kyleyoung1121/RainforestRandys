extends Node

@export var initial_state: State


var current_state: State
var states: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func init(parent: CharacterBody3D) -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			child.parent = parent
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state:
		current_state.update(delta)


func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)


func on_sight_body_entered():
	if current_state:
		current_state.on_sight_body_entered()


func on_sight_body_exited():
	if current_state:
		current_state.on_sight_body_exited()


func on_player_spotted():
	if current_state:
		current_state.on_player_spotted()


func on_player_lost():
	if current_state:
		current_state.on_player_lost()


func on_child_transition(state: State, new_state: State):
	print("New state: ", new_state)
	if state != current_state:
		return
	
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
	
