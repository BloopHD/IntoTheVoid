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
#	if body != null:
#		if body.is_in_group("attackable"):
#			actor.attackable_targets.append(body)
#		else:
#			actor.location_targets.append(body)
	
	actor.target = body
	
	if team == 1:
		print("Changing state to: ", new_state, " Target: ", body)
		print("Targets, ", actor.attackable_targets.size())
	
	if current_state != death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)
		
		
func provide_location(location: Node2D) -> void:
	actor.location_targets.append(location)



#region Signals

func _on_stand_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		var target: Node2D = actor.target
	
		if target != body:
			actor.attackable_targets.erase(body)
			actor.attackable_targets.append(actor.target)
			target = body

		change_state(target,standing_attack_state)
		

func _on_stand_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		if actor.target == body:
			change_state(body, attack_state)
			

func _on_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		var target: Node2D = actor.target
	
		if target != body:
			actor.attackable_targets.erase(body)
			actor.attackable_targets.append(actor.target)
			target = body

		change_state(target,attack_state)
		

func _on_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		if actor.target == body:
			change_state(body, chase_state)
			

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		
		var target: Node2D = actor.target

		if target != body:
			actor.attackable_targets.erase(body)
			actor.attackable_targets.append(actor.target)
			actor.attackable_targets.push_front(body)
			target = body

		change_state(target,chase_state)
		

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:

		if actor.target == body:
			change_state(body, aware_state)
			
			

func _on_aware_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		print("Entered aware detection area, ", body)
		
		# TODO: This causes a bug, our map_ai is telling our units their target is the capturable location.
		# This sets our actor's target to the capturable location. So the first enemy unit enters the 
		# aware detection area, they are instantly put into the attackable_targets array. This causes the capurable location 
		# to be put into the array and eventually targeted and attacked by the actor.
		
		if actor.target == null:
			print("target: ", actor.target, " body: ", body)
			change_state(body, aware_state)

		else:
			actor.attackable_targets.append(body)
			

func _on_aware_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
	
	# TO KNOW: 
	# When a unit is destroyed/qued_free, it's null body is passed to this exit function first and 
	# continues to exit chase, attack, and stand_attack states. In this order.
			
		# This should also catch actor.targets that have been destroyed. B/c destroyed units exit the outter 
		# most detection area first. (aware)
		if actor.target == body:
			if actor.attackable_targets.size() > 0:
				var target = actor.attackable_targets.pop_front()
				change_state(target, attack_state)
			else:
				change_state(null, wander_state)
		
		else:
			if actor.attackable_targets.size() > 0:
				actor.attackable_targets.erase(body)
				
		
#endregion
		
