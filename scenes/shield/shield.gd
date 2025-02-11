extends Area2D
class_name Shield


signal shield_health_changed(new_shield_health: int)

@export var shield_health: int = 100
@export var shield_sprite: Sprite2D

@onready var fade_timer: Timer = $FadeTimer
@onready var shield_regen_timer: Timer = $ShieldRegenTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var shield_color = Color8(0, 255, 195, 60)
var shield_fully_transparent = Color8(0, 255, 195, 0)

var shield_team: int = -1

var fade_in: bool = false
var fully_visible: bool = false
var start_fade: bool = false
var begin_regin: bool = false


func _physics_process(_delta: float) -> void:
	if fade_in && !fully_visible:
		shield_fade_in()
		
	elif !fade_in:
		fully_visible = false
		shield_fade_out()
		
	if begin_regin:
		damage_shield(-5)
		if shield_health >= 100:
			begin_regin = false
		
		
func initialize_shield(team: int) -> void:
	shield_team = team


func damage_shield(damage: int) -> void:
	shield_health -= damage
	fade_in = true

	fade_timer.start()
	shield_regen_timer.start()
	
	if shield_health <= 0:
		collision_shape.call_deferred("set_disabled", true)
		sprite.set_visible(false)
		return

		
func shield_fade_in() -> void:
	if shield_sprite.modulate.a8 < shield_color.a8:
		shield_sprite.modulate = lerp(shield_sprite.modulate, shield_color, 0.3)
	
	else:
		fully_visible = true
		
	
func shield_fade_out() -> void:
	shield_sprite.modulate = lerp(shield_sprite.modulate, shield_fully_transparent, 0.005)
	

func _on_fade_timer_timeout() -> void:
	fade_in = false


func _on_shield_regen_timer_timeout() -> void:
	collision_shape.call_deferred("set_disabled", false)
	sprite.modulate = shield_fully_transparent
	sprite.set_visible(true)
	fully_visible = false
	fade_in = true
	begin_regin = true
	
