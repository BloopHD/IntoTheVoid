extends Node

@export var context_number_of_rays: float = 8

func _ready() -> void:
	for i in context_number_of_rays:
		var angle: float = i * 360 / context_number_of_rays
		print(angle)
		
		var angle_2: float = i * 2 * PI / context_number_of_rays
		angle_2 = rad_to_deg(angle_2)
		print(angle_2)
		
		print("--")
		
