extends Node2D


const NEW_PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const NEW_FREE_MOVE_CAMERA: PackedScene = preload("res://scenes/testing_scenes/free_move_camera.tscn")

@onready var ally_map_ai: Node2D = $AllyMapAI
@onready var enemy_map_ai: Node2D = $EnemyMapAI
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var capturable_manager: CapturableManager = $CapturableManager
@onready var camera: Camera2D = $Camera2D
@onready var gui: GUI = $GUI

@export var use_free_move_camera: bool = true


func _ready() -> void:
	randomize() # This properly seeds the random number generator.
	GlobalSignals.shot_fired.connect(projectile_manager.handle_spawning_laser)
	
	var ally_respawn_points: Array = $AllyRespawnPoints.get_children()
	var enemy_respawn_points: Array = $EnemyRespawnPoints.get_children()

	var bases: Array = capturable_manager.get_capturable_bases()
	
	ally_map_ai.initialize(bases, ally_respawn_points)
	enemy_map_ai.initialize(bases, enemy_respawn_points)
	
	if use_free_move_camera:
		spawn_free_move_camera()
	else:
		spawn_player()

	
func spawn_player() -> void:
	var player: Player = NEW_PLAYER.instantiate()
	call_deferred("add_child", player)
	
	player.global_position = player_spawn.global_position
	player.call_deferred("set_camera_transform", camera.get_path())
	gui.call_deferred("set_player", player)
	player.died.connect(spawn_player)
	
	
func spawn_free_move_camera() -> void:
	var free_move_camera: FreeMoveCamera = NEW_FREE_MOVE_CAMERA.instantiate()
	call_deferred("add_child", free_move_camera)
		
	#free_move_camera.globl_position = player_spawn.global_position
	free_move_camera.call_deferred("set_camera_transform", camera.get_path())
	
