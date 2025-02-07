extends Node2D

@export var base_capture_start_order: BaseCaptureStartOrder = BaseCaptureStartOrder.FIRST

@onready var team = $Team

enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

var capturable_locations: Array = []


func initialize(new_capturable_locations: Array) -> void:
	capturable_locations = new_capturable_locations
	
	var next_location: Node2D = get_next_capturable_location()
	assign_next_capturable_location_to_children(next_location)
	
	
func get_next_capturable_location() -> Node2D:
	var list_of_locations: Array = range(capturable_locations.size())
	
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_locations = range(capturable_locations.size()-1, -1, -1)

	for i in list_of_locations:
		var location: CapturableLocation = capturable_locations[i]
		if team.team != location.team.team:
			return location
			
	return null
	

func assign_next_capturable_location_to_children(location: Node2D) -> void:
	if location == null:
		return
	
	for unit in get_children():
		if unit == team:
			continue
			
		var ai: AI = unit.ai
		ai.change_state(location, ai.travel_state)
		
		