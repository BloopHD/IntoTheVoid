class_name EnemyAwareState
extends State

@export var actor: Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_func(delta, Vector2.ZERO)
	actor.rotate_function(actor.player.position)


func _enter_state() -> void:
	set_physics_process(true)
	
	

func _exit_state() -> void:
	set_physics_process(false)
