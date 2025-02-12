extends Node2D


const Player = preload("res://scenes/player/player.tscn")

@onready var ally_map_ai: Node2D = $AllyMapAI
@onready var enemy_map_ai: Node2D = $EnemyMapAI
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var capturable_manager = $CapturableManager
@onready var camera: Camera2D = $Camera2D
@onready var gui: GUI = $GUI



func _ready() -> void:
	randomize() # This properly seeds the random number generator.
	GlobalSignals.shot_fired.connect(projectile_manager.handle_spawning_laser)
	
	var ally_respawn_points = $AllyRespawnPoints.get_children()
	var enemy_respawn_points = $EnemyRespawnPoints.get_children()

	var bases = capturable_manager.get_capturable_bases()
	ally_map_ai.initialize(bases, ally_respawn_points)
	enemy_map_ai.initialize(bases, enemy_respawn_points)
	
	spawn_player()

	
func spawn_player() -> void:
	var player: Player = Player.instantiate()
	add_child(player)
	player.global_position = player_spawn.global_position
	player.call_deferred("set_camera_transform", camera.get_path())
	player.died.connect(spawn_player)
	gui.set_player(player)
	