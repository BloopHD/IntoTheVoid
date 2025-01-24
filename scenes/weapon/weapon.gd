extends Node2D

signal weapon_fired(laser, position, rotation, starting_speed)

var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

@onready var Muzzle: Marker2D = $LaserMarkers/LaserMarker
@onready var laser_cooldown: Timer = $LaserCooldown


func fire_weapon(actor_starting_speed: float, actor_rotation: float) -> void:
	if laser_cooldown.is_stopped():
		var laser: Area2D = laser_scene.instantiate()
		var current_directional_speed: float = max(actor_starting_speed, 0.0) # If current speed is negative, set it to 0.
		
		laser_cooldown.start()
	
		emit_signal("weapon_fired", laser, Muzzle.global_position, actor_rotation, current_directional_speed)
		
