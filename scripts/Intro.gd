extends Node2D

@onready var label = $Label

const label_script = [
	"Somewhere in spacetime there is a courtroom",
	"The judge, An ex-pro wrestler with a perfect moral compass",
	"His assistant, a warlock capable of summoning the greatest evils",
	"Court is in session"
]
var script_index = 0


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		script_index += 1
		if script_index >= len(label_script):
			get_tree().change_scene_to_file("res://scenes/arena.tscn")
		else:
			label.text = label_script[script_index]
		
