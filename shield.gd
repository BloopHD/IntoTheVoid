extends Area2D

@export var shield_health: float = 100.0
@export var shield_sprite: Sprite2D

var shield_color = Color8(0, 255, 195, 60)
var shield_fully_transparent = Color8(0, 255, 195, 0)

var fade_in: bool = false
var fully_visible: bool = false
var start_fade: bool = false

func _physics_process(_delta: float) -> void:
	
	if fade_in && !fully_visible:
		shield_fade_in()
		
	elif !fade_in:
		fully_visible = false
		shield_fade_out()


func damage_shield(damage: float) -> void:
	
	shield_health -= damage
	fade_in = true
	
	$FadeTimer.start()
	
	if shield_health <= 0:
		queue_free()
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
