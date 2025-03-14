extends Node2D


func handle_spawning_laser(laser: Area2D) -> void:
	self.call_deferred("add_child", laser)
