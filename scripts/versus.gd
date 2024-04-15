extends Node2D

@onready var cslide = $CSlide
@onready var rslide = $RSlide
@onready var rslide_character = $RSlide/character
@onready var lslide = $LSlide
@onready var label = $Label


@export var start_off_screen: bool = true
@export var enemy: String = "Devin"

signal finished

func _ready():
	label.text = enemy
	rslide_character.play(enemy)
	if start_off_screen:
		label.visible = false
		cslide.position.y = -1080
		rslide.position.x = 1920
		lslide.position.x = -1920


func enter_screen():
	var tween = create_tween()
	tween.tween_property(lslide, "position", Vector2(0,0), 0.5)
	await tween.finished
	tween = create_tween()
	tween.tween_property(rslide, "position", Vector2(0,0), 0.5)
	await tween.finished
	tween = create_tween()
	tween.tween_property(cslide, "position", Vector2(0,0), 0.2)
	await tween.finished
	
	label.visible = true
	emit_signal("finished")

func exit_screen():
	label.visible = false
	var tween = create_tween()
	tween.tween_property(cslide, "position", Vector2(0,-1080), 0.2)
	await tween.finished
	tween = create_tween()
	tween.tween_property(rslide, "position", Vector2(1920,0), 0.5)
	tween = create_tween()
	tween.tween_property(lslide, "position", Vector2(-1920,0), 0.5)
	await tween.finished
	emit_signal("finished")
