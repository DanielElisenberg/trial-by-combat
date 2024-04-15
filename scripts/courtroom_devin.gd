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
	text_box.display("Judge Roundhouse", "Let's get one more over with before lunch!")
	can_interact = true
	await advance
	
	text_box.display("Warlock", "This next one is almost too evil to comprehend, sir!")
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
	text_box.display("Warlock", "ARGH! The evil is too intense!!")
	can_interact = true
	await advance
	
	text_box.remove()
	summoning_ring.summon_character("devin")
	await summoning_ring.finished
	warlock.play("default")
	timer.start(1)
	await timer.timeout
	text_box.display("Judge Roundhouse", "You CONSISTENTLY double park, AND ALWAYS use speaker phone on public transport!?")
	can_interact = true
	await advance
	
	text_box.display("Devin", "Whatever!")
	timer.start(1)
	await timer.timeout
	text_box.display("Devin", "Whatever! It's just a prank, bro!")
	timer.start(2)
	await timer.timeout
	text_box.display("Devin", "Whatever, bro!")
	timer.start(1)
	await timer.timeout
	can_interact = true
	await advance

	text_box.display("Warlock", "Wow... What a monster")
	timer.start(2)
	await timer.timeout
	text_box.display("Judge Roundhouse", "...")
	can_interact = true
	await advance
	
	text_box.display("Judge Roundhouse", "TRIAL BY COMBAT!")
	can_interact = true
	await advance

	get_tree().change_scene_to_file("res://scenes/arena_devon.tscn")
	
