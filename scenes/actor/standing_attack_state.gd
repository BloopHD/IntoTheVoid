extends State
class_name StandingAttackState

@export var actor: Actor


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_func(delta, actor.target.position)
	#actor.rotate_function(actor.target.position)
	actor.try_to_shoot()


func _enter_state() -> void:
	set_physics_process(true)
	actor.try_to_shoot()
	
	
func _exit_state() -> void:
	set_physics_process(false)
