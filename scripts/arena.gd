extends Node2D


func _on_player_damage_taken(damage):
	$PlayerHealthBar.take_damage(damage)


func _on_enemy_damage_taken(damage):
	$EnemyHealthBar.take_damage(damage)


func _on_send_projectile(projectile):
	add_child(projectile)
