extends CharacterBody2D

signal laser_shot(laser)

@export var max_speed: int = 500
@export var rotation_speed: int = 250
@export var reverse_speed_multiplier: float = 0.75
@export var strafe_speed_multiplier: float = 0.75
@export var accel: int = 500
@export var friction: int = 100


@onready var muzzle: Marker2D = $LaserMarkers/LaserMarker

var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

const NINETY_DEGREES: int = 90
const NINETY_DEGREES_RAD: float = 1.5708
const FULL_SPEED_MULTI: float = 1.0

var using_m_and_k: bool = false
var can_shoot: bool = true

var curr_speed: float:
	get:
		return velocity.length()

func _input(event: InputEvent) -> void:
	check_input_type(event)

func _process(_delta) -> void:

	check_input()


func _physics_process(delta) -> void:

	player_movement(delta)
	#player_move(delta)

func check_input_type(event: InputEvent) -> void:

	if event is InputEventMouseMotion or event is InputEventMouseButton:
		using_m_and_k = true

	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		using_m_and_k = false

func check_input() -> void:

	if Input.is_action_pressed("primary action") and can_shoot:

		shoot_laser()
		can_shoot = false
		$LaserTimer.start()

	elif Input.is_action_pressed("secondary action"):
		pass
		#print("boom")


func get_thrust() -> float:

	var thrust: float = Input.get_action_strength("forward")
	
	var thrust_all: Vector2 = Input.get_vector("left", "right", "backward", "forward")
	
	print(thrust_all)
	
	return thrust
	
func get_movement() -> Vector2:

	return Input.get_vector("left", "right", "forward", "backward")


# View based movment function
func player_movement(delta) -> void:

	var input_vector: Vector2 = get_movement()
	var look_dir: Vector2 = player_rotation()

	input_vector.y = -input_vector.y

	var thrust: float = input_vector.y
	var strafe: float = input_vector.x

	# Thrusting
	if thrust >= 0.001:
		var new_velocity: Vector2 = velocity
		velocity = activate_thrusters(delta, thrust, Vector2(0,-1), new_velocity, FULL_SPEED_MULTI)

	elif thrust <= -0.001:
		var new_velocity: Vector2 = velocity
		new_velocity = activate_thrusters(delta, thrust, Vector2(0,-1), new_velocity, reverse_speed_multiplier)

		if new_velocity.length() > velocity.length():
			velocity = new_velocity

		else:
			print("here")
			deactivate_thrusters(delta)

	else:
		deactivate_thrusters(delta)

	# Strafing
	if strafe >= 0.001 || strafe <= -0.001:
		var strafe_power: float = (strafe * accel * delta)
		var right_left: Vector2 = Vector2(-look_dir.y, look_dir.x)
		var strafe_velocity: Vector2 = right_left * strafe_power
		velocity += strafe_velocity.limit_length(max_speed * strafe_speed_multiplier)

	else:
		deactivate_thrusters(delta)

	move_and_slide()
	
	
# Ship based movement function.
func player_move(delta) -> void:

	var input_vector: Vector2 = get_movement()
	var look_dir: Vector2 = player_rotation()

	input_vector.y = -input_vector.y

	var thrust: float = input_vector.y
	var strafe: float = input_vector.x

	# Thrusting
	if thrust >= 0.001:
		var new_velocity: Vector2 = velocity
		velocity = activate_thrusters(delta, thrust, look_dir, new_velocity, FULL_SPEED_MULTI)

	elif thrust <= -0.001:
		var new_velocity: Vector2 = velocity
		new_velocity = activate_thrusters(delta, thrust, look_dir, new_velocity, reverse_speed_multiplier)
		
		if new_velocity.length() > velocity.length():
			velocity = new_velocity
		
		else:
			deactivate_thrusters(delta)
			
	else:
		deactivate_thrusters(delta)
	
	# Strafing
	if strafe >= 0.001 || strafe <= -0.001:
		var strafe_power: float = (strafe * accel * delta)
		var right_left: Vector2 = Vector2(-look_dir.y, look_dir.x)
		var strafe_velocity: Vector2 = right_left * strafe_power
		velocity += strafe_velocity.limit_length(max_speed * strafe_speed_multiplier)
		
	else:
		deactivate_thrusters(delta)
	
	move_and_slide()

func activate_thrusters(delta, thrust: float, look_dir: Vector2, new_velocity: Vector2, multiplier: float) ->  Vector2:
	
	var thrust_power: float = (thrust * accel * delta)
	var thrust_velocity: Vector2 = look_dir * thrust_power
	
	new_velocity += thrust_velocity
	new_velocity = new_velocity.limit_length(max_speed * multiplier)
	
	return new_velocity
	
	
func deactivate_thrusters(delta) -> void:

	if curr_speed > (friction * delta):
		velocity -= velocity.normalized() * (friction * delta)

	else:
		velocity = Vector2.ZERO
		
		

func player_rotation() -> Vector2:

	var look_dir: Vector2

	# TODO: Allow turning with A & D. And Controller.
	# var left: float = Input.get_action_strength("left") 
	# var right: float = Input.get_action_strength("right")

	# Keyboard turning controls take priority, so always turn
	# on keyboard input.
	# if (left != 0 || right != 0):
		# TODO: set look_dir to the correct direction.
		# pass 
	
	# Then, if the mouse has not moved stay the direction
	# player is currently facing. Or if the mouse has moved,
	# go ahead and move toward mouse.
	# elif !Input.get_last_mouse_velocity():
	# 	look_dir = (get_global_mouse_position() - position).normalized()
	# 	print(look_dir)
	
	look_dir = (get_global_mouse_position() - position).normalized()
	var angle: float = look_dir.angle() + NINETY_DEGREES_RAD
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, .1))
		
	return look_dir


func _on_timer_timeout() -> void:

	can_shoot = true


func shoot_laser() -> void:

	var laser: Area2D = laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	laser.curr_speed = curr_speed
	emit_signal("laser_shot", laser)
