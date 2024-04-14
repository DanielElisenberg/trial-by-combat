extends Node2D

const round_number_text = {1: "ONE", 2: "TWO", 3: "THREE"}
@onready var flying_text = $FlyingText

var score: Vector2 = Vector2(0, 0)
var round = 0

func _ready():
	next_round()

func _process(delta):
	$Player/PlayerScore.set_text(str(score.x))
	$Enemy/EnemyScore.set_text(str(score.y))


func _on_player_damage_taken(damage):
	$Player/PlayerHealthBar.take_damage(damage)


func _on_enemy_damage_taken(damage):
	$Enemy/EnemyHealthBar.take_damage(damage)


func _on_send_projectile(projectile):
	add_child(projectile)


func _on_enemy_health_bar_health_depleted():
	score.x += 1
	next_round()


func _on_player_health_bar_health_depleted():
	score.y += 1
	next_round()

func next_round():
	$Player/PlayerCharacter.stop()
	$Enemy/EnemyCharacter.stop()
	if score.x < 2 and score.y < 2:
		round += 1
		flying_text.show_text('ROUND ' + round_number_text[round])
		await flying_text.finished
		$Player/PlayerCharacter.reset($Player/PlayerPosition.position)
		$Player/PlayerHealthBar.reset()
		$Enemy/EnemyCharacter.reset($Enemy/EnemyPosition.position)
		$Enemy/EnemyHealthBar.reset()
		flying_text.show_text('FIGHT!')
	elif score.x >= 2:
		flying_text.show_text('VICTORY!')
	else:
		flying_text.show_text('DEFEAT!')
