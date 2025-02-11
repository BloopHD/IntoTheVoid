extends Node2D
class_name Health


@export var health: int = 100:
	set = set_health

var test: int = 50


func set_health(new_health: int) -> void:
	health = clamp(new_health, 0, 100)