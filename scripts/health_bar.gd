extends Sprite2D

@export var health = 100.0
@export_flags("flipped") var flipped
var remaining_health
@onready var missing_health = $MissingHealth

signal health_depleted

func _ready():
	remaining_health = health
	missing_health.flipped = flipped
	missing_health.set_reference_rect($ReferenceRect)

func take_damage(damage: float):
	if remaining_health == 0:
		return
	if remaining_health - damage <= 0:
		remaining_health = 0
		emit_signal("health_depleted")
	else:
		remaining_health -= damage
	missing_health.set_health_percentage(remaining_health / health)

func reset():
	remaining_health = health
	missing_health.set_health_percentage(1)
