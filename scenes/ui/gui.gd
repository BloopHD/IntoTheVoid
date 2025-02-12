extends CanvasLayer
class_name GUI


@onready var health_bar = $MarginContainer/Rows/TopRow/TopLeft/HealthBarMargin/HealthBar
@onready var shield_bar = $MarginContainer/Rows/TopRow/TopLeft/ShieldBarMargin/ShieldBar

var player: Player = null
var player_shield: Shield = null


func set_player(new_player: Player):
	self.player = new_player
	player_shield = player.shield
	
	set_new_health_value(player.health.health)
	set_new_shield_value(player_shield.shield_health)
	
	player.player_health_changed.connect(set_new_health_value)
	player_shield.shield_health_changed.connect(set_new_shield_value)


func set_new_health_value(new_health: int):
	health_bar.value = new_health
	
	
func set_new_shield_value(new_shield: int):
	shield_bar.value = new_shield