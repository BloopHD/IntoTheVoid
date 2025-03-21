extends Node2D
class_name WeaponManager


@export var starting_weapon: PackedScene = preload("res://scenes/weapons/simple_laser.tscn")

@onready var current_weapon: Weapon


var weapons: Array = []


func _ready() -> void:
	var new_weapon: Weapon = starting_weapon.instantiate()
	add_child(new_weapon)
	weapons.append(new_weapon)


func initialize(team: int) -> void:
	for weapon: Weapon in weapons:
		weapon.initialize_weapon(team)
	
	current_weapon = weapons[0]
	

func fire_weapon(directional_aim_speed: float) -> void:
	current_weapon.fire_weapon(directional_aim_speed)
