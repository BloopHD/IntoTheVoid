extends Node2D
class_name Weapon


@onready var Muzzle: Marker2D = $Muzzles/Muzzle
@onready var projectile_cooldown: Timer = $Cooldown

@export var projectile_damage: float = 5.0
@export var projectile_speed: float = 1250.0
@export var projectile_force: float = 5.0
@export var porjectile_lifetime: float = 1.0

var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")

var projectile_team: int = -1
			
			
func initialize_weapon(team: int) -> void:
	projectile_team = team	
	

func fire_weapon(actor_directional_speed: float) -> void:
	if projectile_cooldown.is_stopped():
		
		var projectile: Area2D = projectile_scene.instantiate()
		var projectile_starting_directional_speed: float = max(actor_directional_speed, 0.0) # If current speed is negative, set it to 0.
		
		projectile_cooldown.start()
		
		projectile.initialize_projectile(projectile_damage, projectile_speed, porjectile_lifetime)
		projectile.team = projectile_team
		projectile.position = Muzzle.global_position
		projectile.rotation = global_rotation
		projectile.starting_speed = projectile_starting_directional_speed
		
		GlobalSignals.emit_signal("shot_fired", projectile)		
		
