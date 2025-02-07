class_name WanderState
extends State

@export var actor: Actor

@export var wander_timer: Timer
@export var wander_range: float = 500

var wander_origin: Vector2 = Vector2.ZERO
var wander_location: Vector2 = Vector2.ZERO
var wander_location_reached: bool = true


func _ready():
	set_physics_process(false)
	
	if wander_timer != null and not wander_timer.is_inside_tree(): 
		add_child(wander_timer)


func _process(_delta):
	pass
		

func _physics_process(delta):
	if not wander_location_reached:
		actor.move_func(delta, wander_location)
		if actor.global_position.distance_to(wander_location) < 25:
			wander_location_reached = true
			wander_timer.start()
	else:
		actor.move_func(delta, Vector2.ZERO)


func _enter_state() -> void:
	set_physics_process(true)

	wander_origin = actor.global_position
	wander_timer.call_deferred("start")
	wander_location_reached = true


func _exit_state() -> void:
	set_physics_process(false)

	wander_timer.stop()
	

func _on_wander_timer_timeout():
	var random_x: float = randf_range(-wander_range, wander_range)
	var random_y: float = randf_range(-wander_range, wander_range)

	wander_location = Vector2(random_x, random_y) + wander_origin

	wander_location_reached = false;
	
