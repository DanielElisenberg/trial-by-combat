extends Node2D

@onready var warlock = $Warlock
@onready var summoning_ring = $SummoningRing
@onready var text_box = $TextBox
@onready var timer = $Timer

var can_interact = false

signal advance
 
func _ready():
	initiate_scene()


func _process(_delta):
	if can_interact and Input.is_action_just_pressed("ui_accept"):
		can_interact = false
		emit_signal("advance")


func initiate_scene():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), 3)
	await tween.finished
	timer.start(1)
	await timer.timeout
	text_box.display("Judge Roundhouse", "Who is next on the agenda?")
	can_interact = true
	await advance
	
	text_box.display("Warlock", "Oh it only gets worse, sir! This one is a real bad egg!")
	can_interact = true
	await advance
	
	warlock.play("raised_hands")
	timer.start(1)
	await timer.timeout
	text_box.remove()
	warlock.play("summoning")
	summoning_ring.initiate_runes()
	timer.start(2)
	await timer.timeout
	summoning_ring.summon_character("ceo")
	await summoning_ring.finished
	warlock.play("default")
	timer.start(1)
	await timer.timeout
	text_box.display("Judge Roundhouse", "Your companies make billions. You profit from others suffering. Your greed knows no bounds.")
	can_interact = true
	await advance
	
	text_box.display("CEO", "I'm just a capitalist! I am doing my job!")
	can_interact = true
	await advance

	text_box.display("Judge Roundhouse", "You run a plastic straw factory...")
	timer.start(2)
	await timer.timeout
	text_box.display("Judge Roundhouse", "You run a plastic straw factory... AS A NON PROFIT!")
	can_interact = true
	await advance
	
	text_box.display("CEO", "Everyone needs a hobby!")
	can_interact = true
	await advance

	text_box.display("Judge Roundhouse", "I have heard enough! TRIAL BY COMBAT!")
	can_interact = true
	await advance

	get_tree().change_scene_to_file("res://scenes/arena_ceo.tscn")
	
