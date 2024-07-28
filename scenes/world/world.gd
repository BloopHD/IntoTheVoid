extends Node2D

func _on_player_laser_shot(laser:Variant):
	$Projectiles.add_child(laser)



func _on_asteroid_asteroid_added(new_asteroid:Variant):
	$Asteroids.add_child(new_asteroid)
