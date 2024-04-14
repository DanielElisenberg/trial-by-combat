extends "res://scripts/Projectile.gd"

var fly_direction = -1
@export var bob_speed = 70.0
@export var bob_distance = 50
var fly_range: Vector2

func _ready():
	fly_range = Vector2(position.y - bob_distance/2, position.y + bob_distance/2)

func _process(delta):
	var new_y = clamp(position.y + (bob_speed * delta * fly_direction), fly_range.x, fly_range.y)
	if new_y <= fly_range.x or new_y >= fly_range.y:
		fly_direction *= -1
	process_projectile(delta, Vector2(position.x, new_y))
