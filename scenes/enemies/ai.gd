extends Node2D
class_name AI

@export var actor: Enemy

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var wander_state: Node = $FiniteStateMachine/WanderState
@onready var aware_state: Node = $FiniteStateMachine/AwareState
@onready var chase_state: Node = $FiniteStateMachine/ChaseState
@onready var attack_state: Node = $FiniteStateMachine/AttackState
@onready var death_state: Node = $FiniteStateMachine/DeathState
@onready var standing_attack_state: Node = $FiniteStateMachine/StandingAttackState

var current_state: Node = null

var team: int = -1
		
	
func deferred_initialize(parent_team: int) -> void:
	team = parent_team

		
func change_state(body: Node2D, new_state: Node) -> void:
	actor.target = body
	
	if current_state != death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)
		

#region Signals

func _on_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body, attack_state)

func _on_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body,chase_state)

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body,chase_state)

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body, aware_state)

func _on_aware_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body, aware_state)

func _on_aware_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(null, wander_state)

func _on_stand_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body, standing_attack_state)

func _on_stand_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		change_state(body, attack_state)
		
#endregion
