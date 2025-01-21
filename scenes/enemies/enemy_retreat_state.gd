extends State
class_name EnemyRetreatState

@export var actor: Enemy

func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_func(delta, actor.player.position)
	actor.rotate_function((actor.player.position - actor.position))
	actor.try_to_shoot()


func _enter_state() -> void:
	set_physics_process(true)
	actor.try_to_shoot()



func _exit_state() -> void:
	set_physics_process(false)
