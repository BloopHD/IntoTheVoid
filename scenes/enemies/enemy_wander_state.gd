class_name WanderState
extends State

@export var actor: Enemy

@export var vision_cast: RayCast2D
@export var wander_timer: Timer
@export var wander_range: float = 500
@export var speed: float = 200

@onready var actor_velocity: Vector2 = actor.velocity

var wander_origin: Vector2 = Vector2.ZERO
var wander_location: Vector2 = Vector2.ZERO
var wander_location_reached: bool = true

func _ready():
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)

	wander_origin = actor.global_position
	wander_timer.start()
	wander_location_reached = true

	# if actor.velocity == Vector2.ZERO:
	#     actor.velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * actor.max_speed


func _exit_state() -> void:
	set_physics_process(false)

	wander_timer.stop()


func _process(_delta):
	pass
#	if not wander_location_reached:
#		wander_location_reached = actor.global_position.distance_to(wander_location) < 5
		

func _physics_process(delta):
	if not wander_location_reached:
		actor.move_func(delta, wander_location)
		if actor.global_position.distance_to(wander_location) < 25:
			wander_location_reached = true
			#actor.velocity = Vector2.ZERO
			wander_timer.start()
	else:
		actor.move_func(delta, Vector2.ZERO)


func _on_wander_timer_timeout():
	var random_x: float = randf_range(-wander_range, wander_range)
	var random_y: float = randf_range(-wander_range, wander_range)

	wander_location = Vector2(random_x, random_y) + wander_origin

	wander_location_reached = false;

	#actor.velocity = actor.global_position.direction_to(wander_location) * speed
