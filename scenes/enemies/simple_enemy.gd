class_name Enemy
extends CharacterBody2D

@export var max_speed: int = 750
@export var acceleration: int = 500
@export var friction: int = 100
@export var rotation_speed: int = 250

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var enemy_wander_state: Node = $FiniteStateMachine/EnemyWanderState
@onready var enemy_chase_state: Node = $FiniteStateMachine/EnemyChaseState

var player = null

var engaged_thrusters: bool = false



func move(moveTowards: Vector2, delta: float):
	var thrust_power: float = acceleration * delta
	var thrust_velocity: Vector2 = moveTowards * thrust_power
	
	velocity += thrust_velocity
	velocity = velocity.limit_length(max_speed)

	move_and_slide()

func _on_chase_detection_area_body_entered(body:Node2D):
	if body.is_in_group("player"):
		player = body
		finite_state_machine.change_state(enemy_chase_state)

func _on_chase_detection_area_body_exited(body:Node2D):
	if body.is_in_group("player"):
		player = null
		finite_state_machine.change_state(enemy_wander_state)

