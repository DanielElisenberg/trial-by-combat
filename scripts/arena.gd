extends Node2D

@onready var flying_text = $FlyingText

func _ready():
	flying_text.show_text('ROUND ONE')
	await flying_text.finished
	flying_text.show_text('FIGHT!')


func _on_player_damage_taken(damage):
	$PlayerHealthBar.take_damage(damage)


func _on_enemy_damage_taken(damage):
	$EnemyHealthBar.take_damage(damage)


func _on_send_projectile(projectile):
	add_child(projectile)
