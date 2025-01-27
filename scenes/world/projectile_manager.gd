extends Node2D


func handle_spawning_laser(laser: Area2D, position: Vector2, rotation: float, starting_speed: float) -> void:
	laser.global_position = position
	laser.rotation = rotation
	laser.starting_speed = starting_speed
	add_child(laser)
