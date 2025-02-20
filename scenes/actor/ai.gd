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

var current_target: Node2D = null

var stand_attack_targets: Array = []
var attack_range_targets: Array = []
var chase_range_targets: Array = []
var aware_range_targets: Array = []
		
	
func initialize_ai(parent: Actor, parent_team: int) -> void:
	actor = parent
	team = parent_team

		
func change_state(body: Node2D, new_state: Node) -> void:
#	if body != null:
#		if body.is_in_group("attackable"):
#			actor.attackable_targets.append(body)
#		else:
#			actor.location_targets.append(body)
	
	current_target = body
	actor.target = current_target
	
	if current_state != death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)
		
		
func provide_location(location: Node2D) -> void:
	actor.location_targets.append(location)



#region Signals

func _on_stand_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		attack_range_targets.erase(body)
		
		if body == current_target:
			change_state(current_target, standing_attack_state)
		elif stand_attack_targets.is_empty():
			change_state(body, standing_attack_state)
		else:
			pass
	
		stand_attack_targets.append(body)
		

func _on_stand_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:

		stand_attack_targets.erase(body)
	
		if body.has_method("get_alive_status") and body.get_alive_status():
			if current_target == body:
				change_state(current_target, attack_state)
			
			attack_range_targets.append(body)
			

func _on_attack_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		chase_range_targets.erase(body)

		if body == current_target:
			change_state(current_target, attack_state)
		elif attack_range_targets.is_empty() and stand_attack_targets.is_empty():
			change_state(body, attack_state)
		else:
			pass
	
		attack_range_targets.append(body)
		

func _on_attack_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
			
		attack_range_targets.erase(body)

		if body.has_method("get_alive_status") and body.get_alive_status():
			if current_target == body:
				change_state(current_target, chase_state)
	
			chase_range_targets.append(body)
			

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		
		aware_range_targets.erase(body)
		
		if body == current_target:
			change_state(current_target, chase_state)
		elif chase_range_targets.is_empty() and attack_range_targets.is_empty() and stand_attack_targets.is_empty():
			change_state(body, chase_state)
		else:
			pass
			
		chase_range_targets.append(body)
		

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.has_method("get_team") and body.get_team() != team:
		
		chase_range_targets.erase(body)

		if body.has_method("get_alive_status") and body.get_alive_status():
			if current_target == body:
				change_state(current_target, aware_state)
	
			aware_range_targets.append(body)
			
			
			

func _on_aware_detection_area_body_entered(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		
		# TODO: This causes a bug, our map_ai is telling our units their target is the capturable location.
		# This sets our actor's target to the capturable location. So the first enemy unit enters the 
		# aware detection area, they are instantly put into the attackable_targets array. This causes the capurable location 
		# to be put into the array and eventually targeted and attacked by the actor.
		
		aware_range_targets.append(body)
		
		if current_target == null:
			change_state(body, aware_state)
			

func _on_aware_detection_area_body_exited(body:Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
	
	# TO KNOW: 
	# When a unit is destroyed/qued_free, it's null body is passed to this exit function first and 
	# continues to exit chase, attack, and stand_attack states. In that order.
		
		# We always try to remove the body from the aware_range_targets array.
		aware_range_targets.erase(body)
		
		# Check if the body has been destroyed. If it is not,
		# we try to remove it from the other target arrays.
		if not body.get_alive_status():
			chase_range_targets.erase(body)
			attack_range_targets.erase(body)
			stand_attack_targets.erase(body)
			
		# Here we check for the closest target to the actor and assign them to the current target, and change to approprate state.
		# If there are no targets, we set the current target to null and change the state to wander.
		if not stand_attack_targets.is_empty():
			current_target = stand_attack_targets.front()
			change_state(current_target, standing_attack_state)
		elif not attack_range_targets.is_empty():
			current_target = attack_range_targets.front()
			change_state(current_target, attack_state)
		elif not chase_range_targets.is_empty():
			current_target = chase_range_targets.front()
			change_state(current_target, chase_state)
		else:
			change_state(null, wander_state)
			
				
		
#endregion
		
