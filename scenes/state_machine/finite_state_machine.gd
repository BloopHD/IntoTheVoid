extends Node
class_name FiniteStateMachine

@export var state: State

func _ready():
	change_state(state)

func change_state(new_state: State):
   
	# If state is not Null
	if state is State:
		state._exit_state()

	new_state._enter_state()
	state = new_state
	
	print(new_state)