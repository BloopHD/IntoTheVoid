extends Node2D

@onready var lasers: Node2D = $Lasers
@onready var player: CharacterBody2D = $Player2
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea

var asteroid_scene = preload("res://scenes/asteroid/asteroid.tscn")

var score: int:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	score = 0
	lives = 3
	
	game_over_screen.visible = false
	
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser):
	lasers.add_child(laser)
	
func _on_player_died():
	lives -= 1
	
	player.global_position = player_spawn_pos.global_position
	
	if lives <= 0:
		await  get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)

func _on_asteroid_exploded(pos, size, points):
	score += points
	
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
