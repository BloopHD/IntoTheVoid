extends Node2D
class_name WavesAI

@export var player: Player = null
@export var team_intiger: Team.TeamName = Team.TeamName.NEUTRAL
@export var unit_scene: PackedScene = null
@export var max_units_alive: int = 4

@onready var team: Team = $Team
@onready var unit_container: Node2D = $UnitContainer
@onready var respawn_timer: Timer = $RespawnTimer

func initialize(new_player: Player) -> void:
	if (new_player == null or unit_scene == null):
		push_error("Map AI not properly initialized.")
		return

	player = new_player
	
	for i: int in range(max_units_alive):
		spawn_unit(get_random_location_around_player(player.global_position, 2000))

	
func get_random_location_around_player(player_position: Vector2, distance: float) -> Vector2:
	var random_angle: float = randf() * TAU # TAU is 2 * PI
	var offset: Vector2 = Vector2(cos(random_angle), sin(random_angle)) * distance
	return player_position + offset
	
	
func spawn_unit(spawn_location: Vector2) -> void:
	var unit_instance: Actor = unit_scene.instantiate()
	unit_instance.global_position = spawn_location
	unit_container.add_child(unit_instance)
	unit_instance.died.connect(handle_unit_death)
	unit_instance.ai.provide_player(player)

	print("Unit spawned at: ", spawn_location)
	
	if unit_container.get_child_count() > max_units_alive:
		printerr("Unit container has more units than allowed!!!")
		
		
func handle_unit_death() -> void:
	if respawn_timer.is_stopped():
		respawn_timer.start()
	

func _on_respawn_timer_timeout() -> void:
	if unit_container.get_child_count() < max_units_alive:
		spawn_unit(get_random_location_around_player(player.global_position, 2000))
		
		if unit_container.get_child_count() < max_units_alive:
			respawn_timer.start()
