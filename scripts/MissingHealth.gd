extends Node2D

var health_percentage = 1
var flipped = false
var referenceRect: Control

func set_reference_rect(new_reference_rect: Control):
	referenceRect = new_reference_rect

func _draw():
	var health_bar_rectangle: Rect2 = referenceRect.get_rect()
	var missing_health_rect
	if not flipped:
		missing_health_rect = Rect2(Vector2(health_bar_rectangle.size.x * health_percentage, 0), Vector2(health_bar_rectangle.size.x * (1 - health_percentage), health_bar_rectangle.size.y))
	else:
		missing_health_rect = Rect2(Vector2(0, 0), Vector2(health_bar_rectangle.size.x * (1 - health_percentage), health_bar_rectangle.size.y))
	draw_rect(missing_health_rect, Color.ORANGE_RED, true, 1.0)
	if health_percentage < 1:
		var x = health_bar_rectangle.size.x * health_percentage
		if flipped:
			x = health_bar_rectangle.size.x * (1 - health_percentage)
		draw_line(Vector2(x, 0), Vector2(x, missing_health_rect.size.y), Color.FIREBRICK, 3, false)

func set_health_percentage(percentage):
	health_percentage = percentage
	queue_redraw()
