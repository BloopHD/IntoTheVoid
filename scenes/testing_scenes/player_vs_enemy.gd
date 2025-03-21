extends Node2D

const NEW_PLAYER: PackedScene = preload("res://scenes/player/player.tscn")

@onready var waves_ai: WavesAI = $WavesAI
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var camera: Camera2D = $Camera2D
@onready var gui: GUI = $GUI

var player: Player = null

func _ready() -> void:
	randomize() # This properly seeds the random number generator.
	GlobalSignals.shot_fired.connect(projectile_manager.handle_spawning_projectile)

	spawn_player()
	waves_ai.initialize(player)
	

func spawn_player() -> void:
	player = NEW_PLAYER.instantiate()
	call_deferred("add_child", player)
	player.is_invincible = true
	player.global_position = player_spawn.global_position
	player.call_deferred("set_camera_transform", camera.get_path())
	gui.call_deferred("set_player", player)
	player.died.connect(spawn_player)
