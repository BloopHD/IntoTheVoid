extends Node2D


var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

@onready var Muzzle: Marker2D = $LaserMarkers/LaserMarker
@onready var laser_cooldown: Timer = $LaserCooldown

var can_shoot: bool = true

func fire_weapon() -> void:
	if can_shoot:
		var laser: Area2D = laser_scene.instantiate()
#		var current_directional_speed: float = max(get_speed_in_direction(aim_vector), 0.0) # If current speed is negative, set it to 0.
	
		can_shoot = false
		laser_cooldown.start()
	
#		emit_signal("player_fired_laser", laser, Muzzle.global_position, rotation, current_directional_speed)
