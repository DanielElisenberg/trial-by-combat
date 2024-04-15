extends Node2D

@onready var selector = $Selector
@onready var control_screen = $ControlScreen
const controls_position = Vector2(964, 967)
const play_position = Vector2(964, 833)
var choice = "play"

func _process(delta):
	if control_screen.visible:
		if Input.is_action_just_pressed("ui_accept"):
			control_screen.visible = false
	else:
		if Input.is_action_just_pressed("down"):
			choice = "controls"
			selector.position = controls_position
		if Input.is_action_just_pressed("jump"):
			choice = "play"
			selector.position = play_position
		if Input.is_action_just_pressed("ui_accept"):
			if choice == "play":
				get_tree().change_scene_to_file("res://scenes/intro.tscn")
			else:
				control_screen.visible = true

