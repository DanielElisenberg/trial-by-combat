extends Node2D

@onready var warlock = $Warlock
@onready var summoning_ring = $SummoningRing
@onready var text_box = $TextBox
@onready var timer = $Timer
@onready var versus = $Versus

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
	text_box.display("Judge Roundhouse", "Summon our first defendant, warlock")
	can_interact = true
	await advance
	
	text_box.display("Warlock", "We've got some real big fish biting today, sir.")
	can_interact = true
	await advance
	
	warlock.play("raised_hands")
	text_box.display("Warlock", "I will summon the first miscreant")
	can_interact = true
	await advance
	
	text_box.remove()
	warlock.play("summoning")
	summoning_ring.initiate_runes()
	timer.start(2)
	await timer.timeout
	summoning_ring.summon_character("satan")
	await summoning_ring.finished
	warlock.play("default")
	timer.start(1)
	await timer.timeout
	text_box.display("Judge Roundhouse", "Satan, Father of lies, King of the bottomless pit...")
	timer.start(1)
	await timer.timeout
	text_box.display("Judge Roundhouse", "Satan, Father of lies, King of the bottomless pit... A REAL jerk.")
	can_interact = true
	await advance
	
	text_box.display("Judge Roundhouse", "You have been summoned to this court to answer for your crimes!")
	can_interact = true
	await advance

	text_box.display("Judge Roundhouse", "How do you plead?")
	can_interact = true
	await advance
	
	text_box.display("Satan", "I am just a bad boy hehe")
	can_interact = true
	await advance

	text_box.display("Judge Roundhouse", "PREPARE FOR JUSTICE! TRIAL BY COMBAT!")
	can_interact = true
	await advance

	versus.enter_screen()
	await versus.finished
	timer.start(1.5)
	await timer.timeout

	get_tree().change_scene_to_file("res://scenes/arena.tscn")
	
