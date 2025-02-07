extends CharacterBody2D
class_name Actor


@export var max_speed: int = 750
@export var acceleration: int = 50
@export var friction: int = 50
@export var rotational_accel: float = 5

@export var muzzle: Marker2D
@export var player_test: Node2D

@onready var team: Team = $Team
@onready var health: Health = $Health
@onready var shield: Shield = $Shield
@onready var weapon: Weapon = $Weapon
@onready var ai: AI = $AI

var target: Node2D = null

const ONE_HUNDRED: int = 100

var move_direction: Vector2
var look_direction: Vector2

var aim_vector: Vector2 = Vector2.ZERO
var previous_aim_vector: Vector2 = Vector2.ZERO

var angle_to_target_in_range: bool = false
var moving_forward: bool = false

var curr_speed: float:
	get:
		return velocity.length()


func _ready() -> void:
	ai.initialize_ai(self, team.team)
	weapon.initialize_weapon(team.team)
	shield.initialize_shield(team.team)


func move_func(delta: float, target_location: Vector2) -> void:
	if target_location != Vector2.ZERO:
		rotate_function(target_location)
		
		self.move_direction = (target_location - position).normalized()

		if moving_forward:
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration / ONE_HUNDRED)

		else:
			velocity = lerp(velocity, move_direction * max_speed, delta * acceleration * 0.75 / ONE_HUNDRED)
		
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * friction / ONE_HUNDRED)

	move_and_slide()
	
	
func rotate_function(aim_position: Vector2 = Vector2.ZERO) -> void:
	look_direction = (aim_position - position).normalized()

	var target_rotation_angle: float = look_direction.angle()
	var target_in_range_angle: float = 15
	var moving_forward_angle: float = 30
	
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, target_rotation_angle, rotational_accel / ONE_HUNDRED))
	
	angle_to_target_in_range = check_within_angle_range(target_rotation_angle, target_in_range_angle)
	moving_forward = check_within_angle_range(target_rotation_angle, moving_forward_angle)
	
	
func check_within_angle_range(target_angle: float, degree_range: float) -> bool:
	if abs(abs(rotation_degrees) - abs(rad_to_deg(target_angle))) < degree_range:
		return true
		
	else:
		return false
	

func try_to_shoot():
	if angle_to_target_in_range:
		shoot_laser()
		
		
func shoot_laser() -> void:
	weapon.fire_weapon(team.team, get_speed_in_direction(look_direction))


func get_speed_in_direction(direction: Vector2) -> float:
	var normalized_direction = direction.normalized()
	
	return velocity.dot(normalized_direction)


func get_team() -> int:
	return team.team


func handle_hit(damage: int) -> void: 
	health.health -= damage

	if health.health <= 0:
		queue_free()
		
