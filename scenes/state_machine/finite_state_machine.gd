extends Node
class_name FiniteStateMachine

@export var starting_state: State

var state: State = null

func _ready():
	change_state(starting_state)

func change_state(new_state: State):
	# If state is not Null, safe to call exit_state().
	if state is State:
		state._exit_state()

	new_state._enter_state()
	state = new_state
	
