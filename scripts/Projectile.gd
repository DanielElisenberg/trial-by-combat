extends Area2D

enum Direction {LEFT = -1, RIGHT = 1}

@export var speed = 400.0
@export var direction: Direction
@export var damage = 10.0
@export var hitstun = 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_position = Vector2(position.x + delta * speed * direction, position.y)
	if not get_viewport_rect().has_point(new_position):
		queue_free()
	else:
		set_deferred("position", new_position)


func _on_body_entered(body):
	body.hit(hitstun, damage)
