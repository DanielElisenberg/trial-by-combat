extends Node2D

@onready var name_tag = $Name
@onready var text = $Text
@onready var profile = $Profile
var judge_portrait = preload("res://sprites/portraits/judge.png")
var warlock_portrait = preload("res://sprites/portraits/warlock.png")
var ceo_portrait = preload("res://sprites/portraits/ceo.png")
var devin_portrait = preload("res://sprites/portraits/devin.png")
var satan_portrait = preload("res://sprites/portraits/satan.png")


func _ready():
	visible = false


func display(name: String, display_text: String):
	name_tag.text = name
	text.text = display_text
	if name == 'Judge Roundhouse':
		profile.visible = true
		profile.texture = judge_portrait
	elif name == 'Satan':
		profile.visible = true
		profile.texture = satan_portrait
	elif name == 'Warlock':
		profile.visible = true
		profile.texture = warlock_portrait
	elif name == 'Devin':
		profile.visible = true
		profile.texture = devin_portrait
	elif name == 'CEO':
		profile.visible = true
		profile.texture = ceo_portrait
	else:
		profile.visible = false
	visible = true

func remove():
	visible = false
