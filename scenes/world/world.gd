extends Node2D

@onready var ally_map_ai: Node2D = $AllyMapAI
@onready var enemy_map_ai: Node2D = $EnemyMapAI
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var capturable_manager = $CapturableManager
@onready var player: Player = $Player


func _ready() -> void:
	randomize() # This properly seeds the random number generator.
	GlobalSignals.shot_fired.connect(projectile_manager.handle_spawning_laser)
	
	var bases = capturable_manager.get_capturable_bases()
	ally_map_ai.initialize(bases)
	enemy_map_ai.initialize(bases)
