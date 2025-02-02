extends Node2D

@onready var projectile_manager: Node2D = $ProjectileManager
@onready var player: Player = $Player

func _ready() -> void:
	GlobalSignals.shot_fired.connect(projectile_manager.handle_spawning_laser)
	
