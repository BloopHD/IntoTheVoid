extends Area2D
class_name CapturableLocation

signal location_captured(new_team: int)

@export var neutral_color: Color = Color(1, 1, 1, 0.255)
@export var player_color: Color = Color(0.00, 0.637, 0.384, 0.255)
@export var enemy_color: Color = Color(0.925, 0.266, 0.137, 0.255)

@onready var team: Team = $Team
@onready var capture_timer: Timer = $CaptureTimer
@onready var sprite: Sprite2D = $Sprite2D

var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL


func check_for_base_capture() -> void:
	var majority_team: int = get_team_with_majoirty()
	
	if majority_team == Team.TeamName.NEUTRAL:
		capture_timer.stop()
	elif majority_team == team.team:
		team_to_capture = majority_team
		capture_timer.stop()
	elif majority_team != team.team and capture_timer.is_stopped():
		team_to_capture = majority_team
		capture_timer.start()


func get_location_team() -> int:
	return team.team
	

func get_team_with_majoirty() -> int:
	if player_unit_count > enemy_unit_count:
		return Team.TeamName.PLAYER
		
	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
			
	else:
		return Team.TeamName.NEUTRAL
		
		
func set_team(new_team: int) -> void:
	team.team = new_team
	emit_signal("location_captured", new_team)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
		_:
			pass


func _on_body_entered(body:Node2D) -> void:
	if body.has_method("get_team"):
		
		var body_team: int = body.get_team()
		
		if body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
		elif body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
		else:
			pass

		check_for_base_capture()
		

func _on_body_exited(body:Node2D) -> void:
	if body.has_method("get_team"):
		
		var body_team: int = body.get_team()

		if body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1
		elif body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
		else:
			pass

		check_for_base_capture()

		
func _on_capture_timer_timeout() -> void:
	set_team(team_to_capture)
