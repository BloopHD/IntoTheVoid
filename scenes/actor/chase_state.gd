class_name ChaseState
extends State

@export var actor: Actor


func _ready() -> void:
	set_physics_process(false)
	

func _physics_process(delta: float) -> void:
	actor.move_func(delta, actor.target.position)

	
func _enter_state() -> void:
	set_physics_process(true)

	
func _exit_state() -> void:
	set_physics_process(false)
