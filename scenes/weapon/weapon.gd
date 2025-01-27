extends Node2D
class_name Weapon


@export var PlayerWeapon: bool = false


@onready var Muzzle: Marker2D = $LaserMarkers/LaserMarker
@onready var laser_cooldown: Timer = $LaserCooldown


const PLAYER_PROJECTILE_LAYER: int = 3
const ENEMY_PROJECTILE_LAYER: int = 4
const PLAYER_MASK: int = 1
const ENEMY_MASK: int = 6
const PLAYER_SHIELD_MARK: int = 7
const ENEMY_SHIELD_MARK: int = 8



var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")


func fire_weapon(actor_directional_speed: float, actor_rotation: float) -> void:
	if laser_cooldown.is_stopped():
		
		var laser: Area2D = laser_scene.instantiate()
		
		set_collision_layer_and_masks(laser)

		var laser_starting_directional_speed: float = max(actor_directional_speed, 0.0) # If current speed is negative, set it to 0.
		
		laser_cooldown.start()
	
		GlobalSignals.emit_signal("shot_fired", laser, Muzzle.global_position, actor_rotation, laser_starting_directional_speed)
		

func set_collision_layer_and_masks(laser):
	if PlayerWeapon:
		laser.set_collision_layer_value(PLAYER_PROJECTILE_LAYER, true)
		laser.set_collision_mask_value(ENEMY_MASK, true)
		laser.set_collision_mask_value(ENEMY_SHIELD_MARK, true)
	else:
		print("heere")
		laser.set_collision_layer_value(ENEMY_PROJECTILE_LAYER, true)
		laser.set_collision_mask_value(PLAYER_MASK, true)
		laser.set_collision_mask_value(PLAYER_SHIELD_MARK, true)