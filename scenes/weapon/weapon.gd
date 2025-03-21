extends Node2D
class_name Weapon


@onready var Muzzle: Marker2D = $Muzzles/Muzzle
@onready var laser_cooldown: Timer = $Cooldown

@export var projectile_damage: float = 5.0
@export var projectile_speed: float = 1250.0
@export var projectile_force: float = 5.0
@export var porjectile_lifetime: float = 1.0

var laser_scene: PackedScene = preload("res://scenes/projectiles/laser.tscn")

var projectile_team: int = -1
			
			
func initialize_weapon(team: int) -> void:
	projectile_team = team	
	

func fire_weapon(actor_directional_speed: float) -> void:
	if laser_cooldown.is_stopped():
		
		var laser: Area2D = laser_scene.instantiate()
		var laser_starting_directional_speed: float = max(actor_directional_speed, 0.0) # If current speed is negative, set it to 0.
		
		laser_cooldown.start()
		
		laser.initialize_projectile(projectile_damage, projectile_speed, porjectile_lifetime)
		laser.team = projectile_team
		laser.position = Muzzle.global_position
		laser.rotation = global_rotation
		laser.starting_speed = laser_starting_directional_speed
		
		GlobalSignals.emit_signal("shot_fired", laser)		
		