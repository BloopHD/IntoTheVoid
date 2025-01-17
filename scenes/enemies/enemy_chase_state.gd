class_name EnemyChaseState
extends State

@export var actor: Enemy

func _ready() -> void:
	set_physics_process(false)

func _process(_delta):
	pass

func _physics_process(delta) -> void:
	# actor.enemy_rotation(actor.player.position)
	actor.move_func(delta, actor.player.position)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)
