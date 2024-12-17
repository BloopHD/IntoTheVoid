extends Node2D

func laser_shot(laser:Variant):
	$Projectiles.call_deferred("add_child", laser)