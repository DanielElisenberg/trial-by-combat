extends Node2D

@onready var runes = $runes
@onready var character = $character
@onready var timer = $Timer

signal finished


func _ready():
	runes.visible = false
	character.visible = false

func initiate_runes():
	runes.visible = true
	runes.play("initiate")
	await runes.animation_finished
	runes.play("spin")

func summon_character(name: String):
	if name == "devin":
		character.play("devin_summon")
	elif name == "satan":
		character.play("satan_summon")
	else:
		character.play("ceo_summon")
	character.visible = true
	timer.start(2)
	await timer.timeout
	if name == "devin":
		character.play("devin_idle")
	elif name == "satan":
		character.play("satan_idle")
	else:
		character.play("ceo_idle")
	runes.visible = false
	emit_signal("finished")
