extends CharacterBody2D
class_name FreeMoveCamera

@onready var camera_transform: RemoteTransform2D = $CameraTransform

@export var forward_speed: int = 2500

var move_vector: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_vector = get_move_input()


func _physics_process(delta: float) -> void:
	if move_vector > Vector2.ZERO || move_vector < Vector2.ZERO:
		velocity += move_vector * 1000 * delta
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func get_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func set_camera_transform(camera_path: NodePath) -> void:
	camera_transform.remote_path = camera_path
