extends Node2D
class_name Weapon


@onready var Muzzle: Marker2D = $LaserMarkers/LaserMarker
@onready var laser_cooldown: Timer = $LaserCooldown


const PLAYER_PROJECTILE_LAYER: int = 3
const ENEMY_PROJECTILE_LAYER: int = 4
const PLAYER_MASK: int = 1
const ENEMY_MASK: int = 6
const PLAYER_SHIELD_MARK: int = 7
const ENEMY_SHIELD_MARK: int = 8


var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

var PlayerWeapon: bool = false


func _ready() -> void:
	for i in self.get_parent().get_groups():
		if i == "player":
			PlayerWeapon = true
			break
			
		else:
			PlayerWeapon = false
			break
	

func fire_weapon(actor_directional_speed: float) -> void:
	if laser_cooldown.is_stopped():
		
		var laser: Area2D = laser_scene.instantiate()
		var laser_starting_directional_speed: float = max(actor_directional_speed, 0.0) # If current speed is negative, set it to 0.
		
		set_collision_layer_and_masks(laser)	
	
		laser_cooldown.start()

		laser.position = Muzzle.global_position
		laser.rotation = global_rotation
		laser.starting_speed = laser_starting_directional_speed
		
		GlobalSignals.emit_signal("shot_fired", laser)		

		
func set_collision_layer_and_masks(laser):
	if PlayerWeapon:
		laser.set_collision_layer_value(PLAYER_PROJECTILE_LAYER, true)
		laser.set_collision_mask_value(ENEMY_MASK, true)
		laser.set_collision_mask_value(ENEMY_SHIELD_MARK, true)
	
	else:
		laser.set_collision_layer_value(ENEMY_PROJECTILE_LAYER, true)
		laser.set_collision_mask_value(PLAYER_MASK, true)
		laser.set_collision_mask_value(PLAYER_SHIELD_MARK, true)
