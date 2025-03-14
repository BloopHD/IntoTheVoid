extends Node2D
class_name WeaponManager


@onready var current_weapon: Weapon = $SimpleLaser


var weapons: Array = []


func _ready() -> void:
	weapons = get_children()


func initialize(team: int) -> void:
	for weapon: Weapon in weapons:
		weapon.initialize_weapon(team)


# This function checks if the player has fired a weapon.
func check_for_weapons_fired(directional_aim_speed: float) -> void:

	if Input.is_action_pressed("primary action"):
		current_weapon.fire_weapon(directional_aim_speed)
	elif Input.is_action_pressed("secondary action"):
		pass
	else:
		pass