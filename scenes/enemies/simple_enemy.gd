class_name Enemy
extends CharacterBody2D

signal laser_shot(laser)

@export var max_speed: int = 750
@export var acceleration: int = 70
@export var friction: int = 50
@export var rotational_accel: float = 1

@export var health: int = 100

@export var muzzle: Marker2D

@export var player_test: Node2D

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var enemy_wander_state: Node = $FiniteStateMachine/EnemyWanderState
@onready var enemy_aware_state: Node = $FiniteStateMachine/EnemyAwareState
@onready var enemy_chase_state: Node = $FiniteStateMachine/EnemyChaseState
@onready var enemy_attack_state: Node = $FiniteStateMachine/EnemyAttackState
@onready var enemy_death_state: Node = $FiniteStateMachine/EnemyDeathState
@onready var enemy_retreat_state: Node = $FiniteStateMachine/EnemyRetreatState
var current_state: Node = null

var laser_scene: PackedScene = preload("res://scenes/laser/enemy_laser.tscn")

const NINETY_DEGREES_RAD: float = 1.5708
const NINETY_DEGREES_DEG: float = 90
const ONE_HUNDRED: int = 100

var player: Node2D = null
var move_towards: Vector2 = Vector2.ZERO
var move_direction: Vector2
var look_direction: Vector2

var aim_vector: Vector2 = Vector2.ZERO
var previous_aim_vector: Vector2 = Vector2.ZERO

var engaged_thrusters: bool = false
var can_shoot: bool = true 
var player_in_range: bool = false

var curr_speed: float:
	get:
		return velocity.length()


#func _process(_delta: float) -> void:
#	check_health()


func move_func(delta: float, move_direction: Vector2) -> void:
	
	move_direction = (move_direction - position).normalized()

	var current_rotation_vector: Vector2 = Vector2(cos(rotation), sin(rotation))
	var current_forward_angle: float = rad_to_deg(move_direction.angle_to(current_rotation_vector)) - NINETY_DEGREES_DEG
	
	print("enemy ", move_direction, " ", rotation)	

	var forward_angle_max: float = 30

	#rotate_func(get_rotation_angle(player_position))


	# TODO - This really needs to be refactored, and player_in_range does not quite work.

	if current_state == enemy_chase_state || current_state == enemy_retreat_state || current_state == enemy_attack_state:
		if current_forward_angle < forward_angle_max && current_forward_angle > -forward_angle_max:
			print("FORWARD")
			player_in_range = true
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration / ONE_HUNDRED)
		
		else:
			print("NOT")
			player_in_range = false
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration * 0.75 / ONE_HUNDRED)
		
	elif curr_speed > (friction * delta):
		velocity = lerp(velocity, move_direction * max_speed, delta * friction / ONE_HUNDRED)
	
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func rotate_func(angle: float) -> void:

	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, rotational_accel / ONE_HUNDRED))


func get_rotation_angle(player_position: Vector2) -> float:

	look_direction = (player_position - position).normalized()

	var angle: float = look_direction.angle() + NINETY_DEGREES_RAD

	return angle
	
	
func rotate_function(aim_position: Vector2 = Vector2.ZERO) -> void:

	look_direction = (aim_position - position).normalized()

	var angle: float = look_direction.angle() + NINETY_DEGREES_RAD

	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, rotational_accel / ONE_HUNDRED))

	
func try_to_shoot():
	
	if can_shoot && player_in_range:
		can_shoot = false
		$ShootingTimer.start()
		shoot_laser()

		
func shoot_laser() -> void:
		
	var laser: Area2D = laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	laser.curr_speed = curr_speed
	emit_signal("laser_shot", laser)


func check_health() -> void:

	if health <= 0:
		current_state = enemy_death_state
		finite_state_machine.change_state(current_state)
		queue_free()
		
	
func change_state(body: Node2D, new_state: Node) -> void:
	
	player = body
	
	if current_state != enemy_death_state:
		current_state = new_state
		finite_state_machine.change_state(new_state)


#region Signals

func _on_shooting_timer_timeout() -> void:
	can_shoot = true

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
		
