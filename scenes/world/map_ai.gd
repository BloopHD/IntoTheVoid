extends Node2D

@export var base_capture_start_order: BaseCaptureStartOrder = BaseCaptureStartOrder.FIRST
@export var team_intiger: Team.TeamName = Team.TeamName.NEUTRAL
@export var unit: PackedScene = null
@export var max_units_alive: int = 4

@onready var team = $Team
@onready var unit_container = $UnitContainer
@onready var respawn_timer: Timer = $RespawnTimer

enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

var target_location: CapturableLocation = null
var capturable_locations: Array = []
var spawn_points: Array = []

var current_unit_count: int = 0

var next_spawn_to_use: int = 0


func initialize(capturable_locations: Array, spawn_points: Array) -> void:
	
	if (capturable_locations.size() == 0 or spawn_points.size() == 0 or unit == null):
		push_error("Map AI not properly initialized.")
		return
	
	team.team = team_intiger

	self.capturable_locations = capturable_locations
	
	for location in capturable_locations:
		location.location_captured.connect(handle_location_captured)

	check_for_next_capturable_location()		

	self.spawn_points = spawn_points

	for spawn in spawn_points:
		if current_unit_count >= max_units_alive:
			break
		spawn_unit(spawn.global_position)
		
	print(current_unit_count)
	
	
func handle_location_captured(_new_team: int) -> void:
	
	check_for_next_capturable_location()
	
	
func check_for_next_capturable_location():
	
	target_location = get_next_capturable_location()
	assign_next_capturable_location_to_children(target_location)
	
	
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
	
	for unit in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)
		
	
func set_unit_ai_to_advance_to_next_base(unit: Actor) -> void:
	
	var ai: AI = unit.ai
	ai.provide_location(target_location)
		
	
func spawn_unit(spaw_location: Vector2) -> void:
	
	current_unit_count += 1
	
	var unit_instance: Actor = unit.instantiate()
	unit_instance.global_position = spaw_location
	unit_container.add_child(unit_instance) #swap this with the line unit_instance.global_position = spaw_location. Sets location before physical spawn in.
	unit_instance.died.connect(handle_unit_death)
	set_unit_ai_to_advance_to_next_base(unit_instance)
	
	if team.team == 1:
		print("Spawn Unit: ", current_unit_count)
		print(unit_container.get_child_count())

		
func handle_unit_death() -> void:
	
	if current_unit_count > 0: current_unit_count -= 1
	if team.team == 1: 
		print("Handle Death: ", current_unit_count)
		print(unit_container.get_child_count())
	
	if respawn_timer.is_stopped() and current_unit_count < max_units_alive:
		respawn_timer.start()
	else:
		if team.team == 1:
			print("NUPE")


func _on_respawn_timer_timeout() -> void:
	
	var spawn = spawn_points[next_spawn_to_use]
	spawn_unit(spawn.global_position)
	next_spawn_to_use += 1
	
	if next_spawn_to_use >= spawn_points.size():
		next_spawn_to_use = 0
	
	if current_unit_count < max_units_alive:
		respawn_timer.start()
