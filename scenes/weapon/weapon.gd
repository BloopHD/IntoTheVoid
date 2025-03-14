extends Node2D
class_name Weapon


@onready var Muzzle: Marker2D = $Muzzles/Muzzle
@onready var laser_cooldown: Timer = $Cooldown


#const PLAYER_PROJECTILE_LAYER: int = 3
#const ENEMY_PROJECTILE_LAYER: int = 4
#const PLAYER_MASK: int = 1
#const ENEMY_MASK: int = 6
#const PLAYER_SHIELD_MARK: int = 7
#const ENEMY_SHIELD_MARK: int = 8


var laser_scene: PackedScene = preload("res://scenes/projectiles/laser.tscn")

var projectile_team: int = -1
			
			
func initialize_weapon(team: int) -> void:
	projectile_team = team	
	

func fire_weapon(actor_directional_speed: float) -> void:
	if laser_cooldown.is_stopped():
		
		var laser: Area2D = laser_scene.instantiate()
		var laser_starting_directional_speed: float = max(actor_directional_speed, 0.0) # If current speed is negative, set it to 0.
	
		laser_cooldown.start()

		laser.team = projectile_team
		laser.position = Muzzle.global_position
		laser.rotation = global_rotation
		laser.starting_speed = laser_starting_directional_speed
		
		GlobalSignals.emit_signal("shot_fired", laser)		
		