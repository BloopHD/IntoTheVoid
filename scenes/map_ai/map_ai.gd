extends Node2D

@export var base_capture_start_order: BaseCaptureStartOrder = BaseCaptureStartOrder.FIRST
@export var team_intiger: Team.TeamName = Team.TeamName.NEUTRAL
@export var unit_scene: PackedScene = null
@export var max_units_alive: int = 4

@onready var team: Team = $Team
@onready var unit_container: Node2D = $UnitContainer
@onready var respawn_timer: Timer = $RespawnTimer

enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

var target_location: CapturableLocation = null

var capturable_locations: Array = []
var spawn_points: Array = []

var next_spawn_to_use: int = 0


# Initializes the map AI with capturable locations and spawn points
func initialize(new_capturable_locations: Array, new_spawn_points: Array) -> void:
	if (new_capturable_locations.size() == 0 or new_spawn_points.size() == 0 or unit_scene == null):
		push_error("Map AI not properly initialized.")
		return

	team.team = team_intiger
	capturable_locations = new_capturable_locations
	spawn_points = new_spawn_points

	for location: CapturableLocation in capturable_locations:
		location.location_captured.connect(handle_location_captured)

	check_for_next_capturable_location()

	for spawn: Marker2D in spawn_points:
		if unit_container.get_child_count() < max_units_alive:
			spawn_unit(spawn.global_position)

			
# Handles the event when a location is captured
func handle_location_captured(_new_team: int) -> void:
	check_for_next_capturable_location()

	for unit: Actor in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)

		
# Checks and sets the next capturable location
func check_for_next_capturable_location() -> void:
	target_location = get_next_capturable_location()

	
# Gets the next capturable location based on the capture order
func get_next_capturable_location() -> Node2D:
	var list_of_locations: Array = range(capturable_locations.size())

	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_locations = range(capturable_locations.size()-1, -1, -1)

	for i: int in list_of_locations:
		var location: CapturableLocation = capturable_locations[i]

		if team.team != location.team.team:
			return location

	return null

	
# Provides the AI of a unit the next base/target location.
func set_unit_ai_to_advance_to_next_base(unit: Actor) -> void:
	unit.ai.provide_location(target_location)

	
# Spawns a unit at the given spawn location
func spawn_unit(spaw_location: Vector2) -> void:
	
	var unit_instance: Actor = unit_scene.instantiate()
	unit_instance.global_position = spaw_location
	
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		unit_instance.rotate(deg_to_rad(180))
	
	unit_container.add_child(unit_instance) #swap this with the line unit_instance.global_position = spaw_location. Sets location before physical spawn in.
	unit_instance.died.connect(handle_unit_death)
	set_unit_ai_to_advance_to_next_base(unit_instance)

	if unit_container.get_child_count() > max_units_alive:
		printerr("Unit container has more units than allowed!!!")
	
# Handles the event when a unit dies
func handle_unit_death() -> void:
	if respawn_timer.is_stopped():
		respawn_timer.start()

		
# Handles the respawn timer timeout event
func _on_respawn_timer_timeout() -> void:
	var spawn: Marker2D = spawn_points[next_spawn_to_use]
		
	# TODO: This feels poorly done, I think we should be able to keep track of the units in the unit container and not have to rely on checking it every time.
	# TODO: We also should probably try to move this, right now the timer is always called on unit death and then we decide if we can spawn a unit when it times out.
	# TODO: This means we may be unnecessarily running the timer when we don't need to.
	# TODO: But is that unnecessary? Can we just always assume we need to run the timer upon death? If a unit dies we know we need to spawn another, so... maybe this is fine?
	
	# We need to check if we can spawn a unit before we do so. This is just a safety check.
	if unit_container.get_child_count() < max_units_alive:
		spawn_unit(spawn.global_position)
		# After spawning a unit, we need to check if we can spawn another unit. If so we start the respawn timer again.
		if  unit_container.get_child_count() < max_units_alive:
			respawn_timer.start()

	next_spawn_to_use += 1

	if next_spawn_to_use >= spawn_points.size():
		next_spawn_to_use = 0
	
