extends Node2D
class_name AI

@export var actor: Actor

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var wander_state: Node = $FiniteStateMachine/WanderState
@onready var aware_state: Node = $FiniteStateMachine/AwareState
@onready var chase_state: Node = $FiniteStateMachine/ChaseState
@onready var attack_state: Node = $FiniteStateMachine/AttackState
@onready var death_state: Node = $FiniteStateMachine/DeathState
@onready var standing_attack_state: Node = $FiniteStateMachine/StandingAttackState
@onready var travel_state: Node = $FiniteStateMachine/TravelState
@onready var idle_state: Node = $FiniteStateMachine/IdleState

var current_state: Node = null

var team: int = -1
		
	
func initialize_ai(parent: Actor, parent_team: int) -> void:
	actor = parent
	team = parent_team

		
func change_state(body: Node2D, new_state: Node) -> void:
	actor.target = body
	
	if team == 1:
		print("Changing state to: ", new_state, " Enemy: ", body)
	
	if current_state != death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)
		
		
# This function makes sure that the target still exsits.
# This helps when the target is destroyed. Keep us from trying to access a null target.
func target_exists() -> bool:
	return actor.target != null
	
	

#region Signals

func _on_stand_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		var target: Node2D = actor.target

		if target != body:
			actor.enemy_targets.erase(body)
			actor.enemy_targets.append(actor.target)
			target = body
		
		change_state(target, standing_attack_state)

func _on_stand_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		
		
		
		if is_instance_valid(body):
			if team == 1:
				print("Check 1, ", body)
			change_state(body, attack_state)
		else:
			if actor.enemy_targets.size() > 0:
				print("Check 2, ", body)
				var target = actor.enemy_targets.pop_front()
				change_state(target, attack_state)
			else:
				change_state(null, wander_state)

func _on_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		var target: Node2D = actor.target

		if target != body:
			actor.enemy_targets.erase(body)
			actor.enemy_targets.append(actor.target)
			target = body
		
		change_state(target, attack_state)

func _on_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		if target_exists():
			change_state(body, chase_state)
		else:
			if actor.enemy_targets.size() > 0:
				var target = actor.enemy_targets.pop_front()
				change_state(target, attack_state)
			else:
				change_state(null, wander_state)

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		
#		if actor.target == null:
#			actor.target = body
#		else:
#			actor.enemy_targets.append(body)

		var target: Node2D = actor.target

		if target != body:
			actor.enemy_targets.erase(body)
			actor.enemy_targets.append(actor.target)
			target = body
			
		change_state(target,chase_state)

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		
#		if body == actor.target:
#			if actor.enemy_targets.size() > 0:
#				actor.target = actor.enemy_targets.pop_front()
#			else:
#				actor.target = null
#		else:
#			if actor.enemy_targets.size() > 0:
#				actor.enemy_targets.erase(body)
#			else:
#				printerr("Error: No targets in enemy_targets array.")
		
		if target_exists():
			change_state(body, aware_state)
		else:
			if actor.enemy_targets.size() > 0:
				var target = actor.enemy_targets.pop_front()
				change_state(target, chase_state)
			else:
				change_state(null, wander_state)

func _on_aware_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		if actor.target == null:
			print("target: ", actor.target, " body: ", body)
			actor.target = body 
			change_state(body, aware_state)
			
		else:
			actor.enemy_targets.append(body)
			

func _on_aware_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		var target: Node2D = null
		
		if body == actor.target:
			if actor.enemy_targets.size() > 0:
				target = actor.enemy_targets.pop_front()
			else:
				target = null
		else:
			if actor.enemy_targets.size() > 0:
				actor.enemy_targets.erase(body)
			else:
				printerr("Error: No targets in enemy_targets array: ")
				for t in actor.enemy_targets:
					printerr(t)
				
		
		change_state(target, wander_state)
		
		
#endregion
