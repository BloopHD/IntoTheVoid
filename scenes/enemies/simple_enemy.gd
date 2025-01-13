class_name Enemy
extends CharacterBody2D

signal laser_shot(laser)

@export var max_speed: int = 750
@export var acceleration: int = 500
@export var friction: int = 100
@export var rotation_speed: float = 0.1

@export var health: int = 100

@export var muzzle: Marker2D

@export var player_test: Node2D

@onready var finite_state_machine: Node = $FiniteStateMachine
@onready var enemy_wander_state: Node = $FiniteStateMachine/EnemyWanderState
@onready var enemy_aware_state: Node = $FiniteStateMachine/EnemyAwareState
@onready var enemy_chase_state: Node = $FiniteStateMachine/EnemyChaseState
@onready var enemy_attack_state: Node = $FiniteStateMachine/EnemyAttackState
@onready var enemy_death_state: Node = $FiniteStateMachine/EnemyDeathState
var current_state: Node = null

var laser_scene: PackedScene = preload("res://scenes/laser/enemy_laser.tscn")

const NINETY_DEGREES_RAD: float = 1.5708

var player: Node2D = null
var move_towards: Vector2 = Vector2.ZERO
var look_dir: Vector2

var engaged_thrusters: bool = false
var can_shoot: bool = true 

var curr_speed: float:
	get:
		return velocity.length()


#func _process(_delta: float) -> void:
#	check_health()


func move(delta: float):

	if current_state != enemy_chase_state:
		if curr_speed > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)

		else:
			velocity = Vector2.ZERO
		
	else:
		var thrust_power: float = acceleration * delta
		var thrust_velocity: Vector2 = thrust_power * look_dir
		
		velocity += thrust_velocity
		velocity = velocity.limit_length(max_speed)

	move_and_slide()
	
	
func enemy_rotation(moveTowards: Vector2, rotation_multi: float = 1.0):
	
	look_dir = (moveTowards - position).normalized()
	var angle: float = look_dir.angle() + NINETY_DEGREES_RAD
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, rotation_speed * rotation_multi))

	
func try_to_shoot():
	
	if can_shoot:
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
		
#endregion
		
