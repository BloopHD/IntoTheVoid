extends Node2D

var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

const NINETY_DEGREES: int = 90

func _on_player_laser(pos, dir, curr_speed):
	var laser = laser_scene.instantiate() as Area2D
	laser.position = pos
	laser.rotation_degrees = rad_to_deg(dir.angle()) + NINETY_DEGREES
	laser.direction = dir
	laser.curr_speed = curr_speed
	print(curr_speed)
	$Projectiles.add_child(laser)
