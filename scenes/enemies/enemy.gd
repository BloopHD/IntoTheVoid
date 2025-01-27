extends CharacterBody2D
class_name Enemy


signal laser_shot(laser)
signal enemy_fired_laser(laser, position, rotation, starting_speed)

@export var max_speed: int = 750
@export var acceleration: int = 50
@export var friction: int = 10
@export var rotational_accel: float = 10

@export var muzzle: Marker2D
@export var player_test: Node2D

@onready var health: Health = $Health
@onready var weapon: Weapon = $Weapon
@onready var ai: AI = $AI

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
var angle_to_player_in_range: bool = false
var moving_forward: bool = false

var curr_speed: float:
	get:
		return velocity.length()


func move_func(delta: float, player_location: Vector2) -> void:
	self.move_direction = (player_location - position).normalized()

	if current_state == enemy_chase_state || current_state == enemy_retreat_state || current_state == enemy_attack_state:
		if moving_forward:
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration / ONE_HUNDRED)
		
		else:
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration * 0.75 / ONE_HUNDRED)
		
	elif curr_speed > (friction * delta):
		velocity = lerp(velocity, move_direction * max_speed, delta * friction / ONE_HUNDRED)
	
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	
func rotate_function(aim_position: Vector2 = Vector2.ZERO) -> void:
	look_direction = (aim_position - position).normalized()

	var target_rotation_angle: float = look_direction.angle() + NINETY_DEGREES_RAD
	var target_in_range_angle: float = 15
	var moving_forward_angle: float = 30
	
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, target_rotation_angle, rotational_accel / ONE_HUNDRED))
	
	angle_to_player_in_range = check_within_angle_range(target_rotation_angle, target_in_range_angle)
	moving_forward = check_within_angle_range(target_rotation_angle, moving_forward_angle)
	
	print("Player in range: ", angle_to_player_in_range)
	print("Moving forward: ", moving_forward)
	
	
func check_within_angle_range(target_angle: float, degree_range: float) -> bool:
	print(abs(rotation_degrees - rad_to_deg(target_angle)))
	if abs(rotation_degrees - rad_to_deg(target_angle)) < degree_range:
		return true
	else:
		return false
	

func try_to_shoot():
	if can_shoot && angle_to_player_in_range:
		can_shoot = false
		$ShootingTimer.start()
		shoot_laser()
		
		
func shoot_laser() -> void:
	weapon.fire_weapon(get_speed_in_direction(look_direction))


func get_speed_in_direction(direction: Vector2) -> float:
	var normalized_direction = direction.normalized()
	
	return velocity.dot(normalized_direction)


func handle_hit(damage: int) -> void: 
	health.health -= damage

	if health.health <= 0:
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
		
