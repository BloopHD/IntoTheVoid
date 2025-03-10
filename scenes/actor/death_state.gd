extends State
class_name DeathState

@export var actor: Actor


func _ready() -> void:
	set_physics_process(false)

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func _enter_state() -> void:
	print("DEAD!")
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)
