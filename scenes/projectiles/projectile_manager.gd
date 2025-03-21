extends Node2D


func handle_spawning_projectile(projectile: Area2D) -> void:
	self.call_deferred("add_child", projectile)
