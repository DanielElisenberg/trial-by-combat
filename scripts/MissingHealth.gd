extends Node2D

var health_percentage = 1

func _draw():
	var health_bar_rectangle: Rect2 = get_parent().get_rect()
	var missing_health_rect = Rect2(health_bar_rectangle.position, Vector2(health_bar_rectangle.size.x * (1 - health_percentage), health_bar_rectangle.size.y))
	draw_rect(missing_health_rect, Color.GRAY, true, 1.0)

func set_health_percentage(percentage):
	health_percentage = percentage
	queue_redraw()
