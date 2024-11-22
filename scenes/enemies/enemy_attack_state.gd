extends State
class_name EnemyAttackState

@export var actor: Enemy

func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move(delta)
	actor.enemy_rotation(actor.player.position)


func _enter_state() -> void:
	set_physics_process(true)



func _exit_state() -> void:
	set_physics_process(false)

