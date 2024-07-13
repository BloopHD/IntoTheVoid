extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

@onready var lives = $Lives

var uilife_scene = preload("res://scenes/UI/ui_life.tscn")

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
