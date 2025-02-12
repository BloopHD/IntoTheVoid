extends Area2D
class_name Shield

signal shield_health_changed(new_shield_health: int)


@export var shield_health: int = 100
@export var shield_sprite: Sprite2D

@onready var fade_out_timer: Timer = $FadeOutTimer
@onready var shield_regen_timer: Timer = $ShieldRegenTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var shield_color = Color8(0, 255, 195, 60)
var shield_fully_transparent = Color8(0, 255, 195, 0)

var shield_team: int = -1

#region State Machines For Shield State and Shield Visiblity.

enum ShieldState {
	FULL_HEALTH, 
	REGENERATING,
	DAMAGED, 
	DESTROYED
}

enum ShieldVisibility {
	INVISIBLE,
	FULLY_VISIBLE,
	FADING_IN,
	FADING_OUT
}

var current_state: ShieldState = ShieldState.FULL_HEALTH:
	set = set_state

func set_state(new_state: ShieldState) -> void:
	if new_state == current_state:
		return

	current_state = new_state

var current_visibility: ShieldVisibility = ShieldVisibility.INVISIBLE:
	set = set_visibility
	
	
func set_visibility(new_visibility: ShieldVisibility) -> void:
	if new_visibility == current_visibility:
		return
	
	current_visibility = new_visibility
	
#endregion For for  for vis

#region For Testing.

#func _process(_delta: float) -> void:
#	if Input.is_action_just_pressed("primary action"):
#		handle_hit(5)

#endregion


func _physics_process(_delta: float) -> void:
	match current_state:
		ShieldState.FULL_HEALTH:
			if current_visibility != ShieldVisibility.INVISIBLE:
				shield_fade_out()
			
		ShieldState.REGENERATING:
			if current_visibility != ShieldVisibility.INVISIBLE: 
				shield_fade_out() 
			
			regen_shield()
				
		ShieldState.DAMAGED:
			if current_visibility == ShieldVisibility.FADING_IN:
				shield_fade_in()
			elif current_visibility == ShieldVisibility.FADING_OUT:
				shield_fade_out()

		ShieldState.DESTROYED:
			collision_shape.call_deferred("set_disabled", true)
			sprite.set_visible(false)
			
		_:
			printerr("Invalid Shield State. Check shield.gd.")
		
		
func initialize_shield(team: int) -> void:
	shield_team = team


func handle_hit(damage: int) -> void:
	current_state = ShieldState.DAMAGED
	current_visibility = ShieldVisibility.FADING_IN
	
	shield_health -= damage

	fade_out_timer.start()
	shield_regen_timer.start()
	
	if shield_health <= 0:
		current_state = ShieldState.DESTROYED
		
		
func regen_shield() -> void:
	if shield_health < 100:
		shield_health += 1
		
	else:
		shield_health = 100
		current_state = ShieldState.FULL_HEALTH
		current_visibility = ShieldVisibility.FADING_OUT
		
		
func shield_fade_in() -> void:
	if shield_sprite.modulate.a8 < shield_color.a8:
		shield_sprite.modulate = lerp(shield_sprite.modulate, shield_color, 0.5)
	
	else:
		current_visibility = ShieldVisibility.FULLY_VISIBLE

		
func shield_fade_out() -> void:
	if shield_sprite.modulate.a8 > shield_fully_transparent.a8:
		shield_sprite.modulate = lerp(shield_sprite.modulate, shield_fully_transparent, 0.01)

	else:
		current_visibility = ShieldVisibility.INVISIBLE


func _on_fade_out_timer_timeout() -> void:
	current_visibility = ShieldVisibility.FADING_OUT
	

func _on_shield_regen_timer_timeout() -> void:
	if current_state == ShieldState.DESTROYED:
		collision_shape.call_deferred("set_disabled", false)
		sprite.set_visible(true)
		sprite.modulate = shield_fully_transparent

	current_state = ShieldState.REGENERATING	
