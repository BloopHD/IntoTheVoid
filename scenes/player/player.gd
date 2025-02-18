extends CharacterBody2D
class_name Player

signal player_health_changed(new_health: int)
signal died()

@export var forward_speed: int = 1000
@export var reverse_and_strafe_speed: int = 750
@export var rotational_accel: float = 15
@export var forward_accel: float = 75
@export var reverse_and_strafe_accel: float = 65
@export var friction: float = 50

@onready var team: Team = $Team
@onready var health: Health = $Health
@onready var shield: Shield = $Shield
@onready var weapon: Weapon = $Weapon
@onready var camera_transform: RemoteTransform2D = $CameraTransform


const FULL_SPEED_MULTI: float = 1.0
const ONE_HUNDRED: int = 100

var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.ZERO
var previous_aim_vector: Vector2 = Vector2.ZERO

var using_m_and_k: bool = false


var current_speed: float:
	get:
		return velocity.length()

func _ready() -> void:
	weapon.initialize_weapon(team.team)
	shield.initialize_shield(team.team)
	

func _input(event: InputEvent) -> void:
	set_input_type(event)

	
func _process(_delta) -> void:
	check_for_input()
		

func _physics_process(delta: float) -> void:
	player_movement(delta)
	player_rotation(get_player_rotation_angle())

	
# Movment function.
func player_movement(delta: float) -> void:
	var forward_angle_max: float = 30
	
	# If the player is moving.
	if move_vector > Vector2.ZERO || move_vector < Vector2.ZERO:
		if check_within_angle_range(move_vector.angle(), forward_angle_max):
			# Moving the direction player is facing.
			velocity = lerp(velocity, move_vector * forward_speed, delta * forward_accel / ONE_HUNDRED)
		else:
			# Moving sideways or backwards.
			velocity = lerp(velocity, move_vector * reverse_and_strafe_speed, delta * reverse_and_strafe_accel / ONE_HUNDRED)
	else:
		# Slowing player down.
		velocity = lerp(velocity, Vector2.ZERO, delta * friction / ONE_HUNDRED)
	
	move_and_slide()


# This function rotates the player.
func player_rotation(angle: float) -> void:
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, rotational_accel / ONE_HUNDRED))


func check_within_angle_range(target_angle: float, angle_in_range: float) -> bool:
	if abs(abs(rotation) - abs(target_angle)) < deg_to_rad(angle_in_range):
		return true

	else:
		return false


# This function gets the angle the player is facing.
func get_player_rotation_angle() -> float:
	var angle: float = 0.0

	# If the player is aiming or moving, use the aim vector to determine the direction the player faces.
	if aim_vector != Vector2.ZERO:
		angle = aim_vector.angle()
	# If the player is not moving or aiming, use the previous aim vector to determine the direction the player faces.
	else:
		angle = previous_aim_vector.angle()

	return angle


# This function checks the type of input the player is using.
func set_input_type(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		using_m_and_k = true

	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		using_m_and_k = false


# This function checks for player game input.
func check_for_input() -> void:
	check_for_weapons_fired()
	move_vector = get_move_input()
	aim_vector = get_aim_input()
	save_aim_vector()


# This function checks if the player has fired a weapon.
func check_for_weapons_fired() -> void:

	if Input.is_action_pressed("primary action"):
		weapon.fire_weapon(team.team, get_directional_speed(aim_vector))
	elif Input.is_action_pressed("secondary action"):
		pass
	else:
		pass


# This function gets the move input from the player.
func get_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


# This function gets the aim input from the player.
func get_aim_input() -> Vector2:
	var aim_input: Vector2 = Vector2.ZERO

	# If the player is using a mouse and keyboard, get the aim input from the mouse position.
	if using_m_and_k:
		aim_input = (get_global_mouse_position() - position).normalized() 
 	# If the player is using a controller, get the aim input from the controller.
	else:
		aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		# If the player is not aiming, set the aim input to the move vector.
		if aim_input == Vector2.ZERO:
			aim_input = move_vector

	return aim_input


# This function saves the current aim vevtor or move vector to allow us to keep the player 
# facing the same direction when they stop moving.
func save_aim_vector() -> void:
	# If the player is aiming, save the aim vector.
	if aim_vector != Vector2.ZERO:
		previous_aim_vector = aim_vector
		# If the player is not aiming but moving, save the move vector.
	elif move_vector != Vector2.ZERO:
		previous_aim_vector = move_vector


# This function gets the speed of the player in a given direction,
# which is used to determine the starting speed of a laser.
func get_directional_speed(direction: Vector2) -> float:
	var normalized_direction = direction.normalized()
	return velocity.dot(normalized_direction)


func set_camera_transform(camera_path: NodePath) -> void:
	camera_transform.remote_path = camera_path


func get_team() -> int:
	return team.team


func handle_hit(damage: int) -> void:
	health.health -= damage
	emit_signal("player_health_changed", health.health)
	
	if health.health <= 0:
		die()
		
		
func die() -> void:
	emit_signal("died")
	queue_free()
