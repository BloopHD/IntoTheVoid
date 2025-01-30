extends Node2D
class_name AI

@export var actor: Enemy

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var enemy_wander_state: Node = $FiniteStateMachine/EnemyWanderState
@onready var enemy_aware_state: Node = $FiniteStateMachine/EnemyAwareState
@onready var enemy_chase_state: Node = $FiniteStateMachine/EnemyChaseState
@onready var enemy_attack_state: Node = $FiniteStateMachine/EnemyAttackState
@onready var enemy_death_state: Node = $FiniteStateMachine/EnemyDeathState
@onready var enemy_retreat_state: Node = $FiniteStateMachine/EnemyRetreatState

var current_state: Node = null

func change_state(body: Node2D, new_state: Node) -> void:
	actor.player = body
	
	if current_state != enemy_death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)
		

#region Signals

func _on_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(body, enemy_attack_state)

func _on_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(body,enemy_chase_state)

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.is_in_group("player"):
		change_state(body,enemy_chase_state)

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.is_in_group("player"):
		change_state(body, enemy_aware_state)

func _on_aware_detection_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(body, enemy_aware_state)

func _on_aware_detection_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(null, enemy_wander_state)

func _on_retreat_detection_area_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(body, enemy_retreat_state)

func _on_retreat_detection_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		change_state(body, enemy_attack_state)

		#endregion
		
