class_name AwareState
extends State

@export var actor: Actor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_func(delta, Vector2.ZERO)
	actor.rotate_function(actor.target.position)


func _enter_state() -> void:
	set_physics_process(true)
	
	

func _exit_state() -> void:
	set_physics_process(false)
