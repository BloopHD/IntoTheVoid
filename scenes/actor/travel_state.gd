extends State
class_name TravelState

@export var actor: Actor

var target_location: Vector2 = Vector2.ZERO
var target_location_reached: bool = false


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not target_location_reached:
		actor.move_func(delta, target_location)
	
		if actor.global_position.distance_to(target_location) < 25 && actor.velocity.length() < 5:
			target_location_reached = true
		
	else:
		actor.ai.change_state(actor.target, actor.ai.idle_state)


func _enter_state() -> void:
	set_physics_process(true)
	target_location = actor.target.position


func _exit_state() -> void:
	set_physics_process(false)
