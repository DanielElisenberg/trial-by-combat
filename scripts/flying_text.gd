extends Node2D

@export var text: String
@onready var label = $Label
@onready var timer = $Timer

signal finished


func show_text(text: String):
	label.text = text
	label.position = Vector2(-label.size.x, 200)
	label.visible = true
	
	var tween = create_tween()
	tween.tween_property(label, "position", Vector2(960-(label.size.x/2), label.position.y), 0.2)
	await tween.finished
	
	timer.start(1)
	await timer.timeout
	
	tween = create_tween()
	tween.tween_property(label, "position", Vector2(1920+label.size.x, label.position.y), 0.2)
	await tween.finished
	label.visible = false
	emit_signal("finished")


func show_permanent_text(text: String):
	label.text = text
	label.position = Vector2(-label.size.x, 200)
	label.visible = true
	
	var tween = create_tween()
	tween.tween_property(label, "position", Vector2(960-(label.size.x/2), label.position.y), 0.2)
