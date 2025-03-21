extends CharacterBody2D
class_name Actor
## Actor class is the parent class for all NPC in the game. It contains the basic functionality that all NPC will need to have.
##
## ToDo: Lots of magic numbers still in this class. Need to refactor them out.
##


signal died()

@export var max_speed: int = 750
@export var acceleration_percentage: int = 50
@export var friction_percentage: int = 50
@export var rotational_acceleration_percentage: float = 5

@export var muzzle: Marker2D
@export var player: Node2D

@onready var team: Team = $Team
@onready var health: Health = $Health
@onready var shield: Shield = $Shield
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var ai: AI = $AI

const ONE_HUNDRED: int = 100

var is_alive: bool = true

# One or both of these may be unnecessary.
var target: Node2D = null
var current_target: Node2D = null

var move_direction: Vector2
var look_direction: Vector2

var is_angle_to_target_in_range: bool = false
var is_moving_forward: bool = false

var aim_vector: Vector2 = Vector2.ZERO
#var previous_aim_vector: Vector2 = Vector2.ZERO

var attackable_targets: Array = []
var location_targets: Array = []

@export var context_based_movement: bool = true
@export var context_distance: int = 500
@export var context_number_of_rays: int = 8
var context_ray_directions: Array = []
var context_interests: Array = []
var context_dangers: Array = []
var context_chosen_direction: Vector2 = Vector2.ZERO
var lines_to_draw: Array =[]

@export var provide_data: bool = false
var print_data: bool = false
var current_context_target: Vector2 = Vector2.ZERO


var curr_speed: float:
	get:
		return velocity.length()


func _ready() -> void:
	ai.initialize_ai(self, team.team)
	weapon_manager.initialize(team.team)
	shield.initialize_shield(team.team)
	ready_context_movement()
	
	
func ready_context_movement() -> void:
	context_ray_directions.resize(context_number_of_rays)
	context_interests.resize(context_number_of_rays)
	context_dangers.resize(context_number_of_rays)
	
	for i: int in context_number_of_rays:
		var angle: float = i * 2 * PI / context_number_of_rays
		context_ray_directions[i] = Vector2.RIGHT.rotated(angle)
		
		
func set_up_context_movement(target_location: Vector2) -> void:
	set_interest_array(target_location)
	set_danger_array()
	choose_direction()


func set_interest_array(target_location: Vector2) -> void:
	if provide_data and current_context_target != target_location and target_location != Vector2.ZERO:
		current_context_target = target_location
		print_data = true
	else:
		print_data = false
		
	
	for i: int in context_number_of_rays:
		if print_data:
			#print("Context Ray: ", i, " ", context_ray_directions[i])
			#print("Context Ray Rotated: ", i, " ", context_ray_directions[i].rotated(rotation))
			pass
			
		var path_direction: Vector2 = (target_location - position).normalized() #.rotated(PI / 4.5)
		
		var dir: float  = context_ray_directions[i].rotated(rotation).dot(path_direction)
		context_interests[i] = max(0, dir)
		if print_data:
			#print("Target Direction: ", i, " ", context_interests[i])
			print("CHECK: ", i)
			print("Dir, ", context_ray_directions[i]) 
			print("Dir Rot: ", context_ray_directions[i].rotated(rotation)) 
			#print(" Int, ", context_interests[i])
			print("----")
		
	if print_data:
		for i: int in context_number_of_rays:
			print("Interest: ", i, " ", context_interests[i])
		print("-------------")
		
		
func set_danger_array() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	for i: int in context_number_of_rays:
		var ray_start: Vector2 = position
		var ray_end: Vector2 = position + context_ray_directions[i].rotated(rotation) * context_distance
	
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
		query.exclude = [self]
		
		var result: Dictionary = space_state.intersect_ray(query)
		
		if result:
			if print_data:
				print("Result: ", i, " Danger! ", result)
			context_dangers[i] = 1.0
		else:
			context_dangers[i] = 0.0

		
func choose_direction() -> void:
	for i: int in context_number_of_rays:
		if context_dangers[i] > 0.0:
			context_interests[i] = 0.0
	
	context_chosen_direction = Vector2.ZERO
	
	for i: int in context_number_of_rays:
		context_chosen_direction += context_ray_directions[i] * context_interests[i]
		
	context_chosen_direction = context_chosen_direction.normalized().rotated(rotation)
			

func move_func(delta: float, target_location: Vector2) -> void:
	
	var travel_location: Vector2 = Vector2.ZERO
	
	# If the target is attackable, get the set the travel location to be a bit away from the target.
	# Else, set the travel location to be the target location.
	if target != null and target.is_in_group("attackable"):
		travel_location = get_travel_to_location(target_location)
	else:
		travel_location = target_location

	set_up_context_movement(travel_location)
	
	if context_based_movement:
		move_direction = context_chosen_direction
	else:
		move_direction = (travel_location - position).normalized()
	
	#print("Travel: ", travel_location)
	#print("Target: ", target_location)
	#print("---")
	
	
	#set_up_context_movement(target_location)
	
	if print_data:
		print("Target: ", target_location)
		print("Actor: ", position)
		#print("Old: ",(target_location - position).normalized())
		#print("New: ", (context_chosen_direction - position).normalized())
		#print("New R: ", (context_chosen_direction.rotated(rotation) - position).normalized())
		print("----")
	
	
	# Watch out for this. Spawns/Locations cannot be at 0,0.
	if target_location != Vector2.ZERO:
		rotate_function(target_location)

		var distance_to_target: float = position.distance_to(travel_location)
		if distance_to_target < 50:
			velocity = lerp(velocity, Vector2.ZERO, delta * friction_percentage / ONE_HUNDRED)
		
		else:
			# clamp(distance_to_target / x, 0.0, 1.0), x is the distance at which the actor will start decelerating, higher the number the sooner the actor will start decelerating.
			# We should probably make this a x value that can be set in the editor.
			var deceleration_factor: float = clamp(distance_to_target / 250.0, 0.0, 1.0)
			#print("Deceleration: ", deceleration_factor)
			
			# If the actor is not decelerating.
			if deceleration_factor == 1.0:
				if is_moving_forward:
					velocity = lerp(velocity, move_direction * max_speed * deceleration_factor, delta * acceleration_percentage / ONE_HUNDRED)
				else:
					velocity = lerp(velocity, move_direction * max_speed * deceleration_factor, delta * acceleration_percentage * 0.75 / ONE_HUNDRED)
		
			else:
				velocity = lerp(velocity, move_direction * max_speed * deceleration_factor, delta * friction_percentage / ONE_HUNDRED)

	move_and_slide()


func get_travel_to_location(target_location: Vector2) -> Vector2:
	var direction: Vector2 = (position - target_location).normalized()
	var travel_location: Vector2 = target_location + direction * 250
	return travel_location
	
	
func rotate_function(aim_position: Vector2 = Vector2.ZERO) -> void:
	look_direction = (aim_position - position).normalized()

	var actor_rotation_angle: float = look_direction.angle()
	var target_in_range_angle: float = 15
	var moving_forward_angle: float = 30
	
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, actor_rotation_angle, rotational_acceleration_percentage / ONE_HUNDRED))
	
	is_angle_to_target_in_range = check_within_angle_range(actor_rotation_angle, target_in_range_angle)
	is_moving_forward = check_within_angle_range(actor_rotation_angle, moving_forward_angle)

	
func check_within_angle_range(target_angle: float, degree_range: float) -> bool:
	if abs(abs(rotation_degrees) - abs(rad_to_deg(target_angle))) < degree_range:
		return true
	else:
		return false
		

func context_movement(_delta: float) -> void:
	pass
	

func try_to_shoot() -> void:
	if is_angle_to_target_in_range:
		shoot_laser()

		
func shoot_laser() -> void:
	weapon_manager.fire_weapon(get_speed_in_direction(look_direction))
		
	
func handle_hit(damage: int) -> void: 
	health.health -= damage

	if health.health == 0:
		die()
	elif health.health < 0:
		printerr("Health is less than 0!!!")

		
func die() -> void:
	is_alive = false
	
	emit_signal("died")
	queue_free()
	

func get_speed_in_direction(direction: Vector2) -> float:
	var normalized_direction: Vector2 = direction.normalized()
	
	return velocity.dot(normalized_direction)
	
	
func get_team() -> int:
	return team.team
	
	
func get_alive_status() -> bool:
	return is_alive
