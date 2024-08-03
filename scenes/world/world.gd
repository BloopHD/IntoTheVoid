extends Node2D

func _on_player_laser_shot(laser:Variant):
	$Projectiles.add_child(laser)