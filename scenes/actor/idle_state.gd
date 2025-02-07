extends State
class_name IdleState

@export var actor: Actor


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	# Do nothing. This is the idle state.
	# But we could add some idle movements here,
	# maybe have the actor look around, bob up and down, etc..
	pass


func _enter_state() -> void:
	set_physics_process(true)


func _exit_state() -> void:
	set_physics_process(false)
