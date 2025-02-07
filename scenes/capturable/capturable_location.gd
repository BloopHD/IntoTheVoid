extends Area2D
class_name CapturableLocation

signal base_captured(new_team)

@export var neutral_color: Color = Color(1, 1, 1, 0.255)
@export var player_color: Color = Color(0.00, 0.637, 0.384, 0.255)
@export var enemy_color: Color = Color(0.925, 0.266, 0.137, 0.255)

@onready var team = $Team
@onready var capture_timer = $CaptureTimer
@onready var sprite = $Sprite2D

var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL


func check_for_base_capture() -> void:
	var majority_team = get_team_with_majoirty()
	
	if majority_team == Team.TeamName.NEUTRAL:
		print("Capture point contested, stopping capture clock.")
		capture_timer.stop()
	elif majority_team == team.team:
		print("Owning team is majority, stopping capture clock.")
		#team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
	elif team_to_capture != majority_team:
		print("New team is majority, starting capture clock.")
		team_to_capture = majority_team
		capture_timer.start()


func get_team_with_majoirty() -> int:
	if player_unit_count > enemy_unit_count:
		return Team.TeamName.PLAYER
		
	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
			
	else:
		return Team.TeamName.NEUTRAL
		
		
func set_team(new_team: int) -> void:
	team.team = new_team
	emit_signal("base_captured", new_team)
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
		var body_team = body.get_team()
		
		if body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
		elif body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
		else:
			pass
		
		print("Actor Entered")
		print("Player unit count: ", player_unit_count)
		print("Enemy unit count: ", enemy_unit_count)

		check_for_base_capture()
		

func _on_body_exited(body:Node2D) -> void:
	if body.has_method("get_team"):
		var body_team = body.get_team()

		if body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1
		elif body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
		else:
			pass
			
		print("Actor Exited")
		print("Player unit count: ", player_unit_count)
		print("Enemy unit count: ", enemy_unit_count)	
	
		check_for_base_capture()

func _on_capture_timer_timeout() -> void:
	set_team(team_to_capture)
