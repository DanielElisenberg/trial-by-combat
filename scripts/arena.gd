extends Node2D

const round_number_text = {1: "ONE", 2: "TWO", 3: "THREE"}
@onready var round_sound = {1: $roundSFX/ROUND_ONE, 2: $roundSFX/ROUND_TWO, 3: $roundSFX/FINAL_ROUND}
@onready var flying_text = $FlyingText

var score: Vector2 = Vector2(0, 0)
var round = 0
var game_started = false
var game_finished = false
var victory = false
@export var next_fight: PackedScene
var paused = false
var music_progress = 0

func _ready():
	next_round()

func _process(delta):
	$Player/PlayerScore.set_text(str(score.x))
	$Enemy/EnemyScore.set_text(str(score.y))
	if game_finished and Input.is_action_just_pressed("retry"):
		get_tree().reload_current_scene()
	if game_started and Input.is_action_just_pressed("escape"):
		print("escape pressed")
		if paused:
			resume()
		else:
			pause()


func _on_player_damage_taken(damage):
	$Player/PlayerHealthBar.take_damage(damage)


func _on_enemy_damage_taken(damage):
	$Enemy/EnemyHealthBar.take_damage(damage)


func _on_send_projectile(projectile):
	$Projectiles.add_child(projectile)


func _on_enemy_health_bar_health_depleted():
	score.x += 1
	next_round()


func _on_player_health_bar_health_depleted():
	score.y += 1
	next_round()

func next_round():
	game_started = false
	$Player/PlayerCharacter.stop()
	$Enemy/EnemyCharacter.stop()
	if score.x < 2 and score.y < 2:
		round += 1
		round_sound[round].play()
		flying_text.show_text('ROUND ' + round_number_text[round])
		await flying_text.finished
		$Player/PlayerCharacter.reset($Player/PlayerPosition.position)
		$Player/PlayerHealthBar.reset()
		$Enemy/EnemyCharacter.reset($Enemy/EnemyPosition.position)
		$Enemy/EnemyHealthBar.reset()
		for projectile in $Projectiles.get_children():
			projectile.queue_free()
		$FIGHT.play()
		flying_text.show_text('FIGHT!')
		$BattleMusic.play()
		game_started = true
	elif score.x >= 2:
		$VICTORY.play()
		flying_text.show_text('VICTORY!')
		await flying_text.finished
		$Timer.start(2)
		await $Timer.timeout
		get_tree().change_scene_to_packed(next_fight)
	else:
		pause()
		$DEFEAT.play()
		flying_text.show_text('DEFEAT!')
		await flying_text.finished
		flying_text.show_permanent_text('press space to retry!')
		game_finished = true

func pause():
	paused = true
	music_progress = $BattleMusic.get_playback_position()
	$BattleMusic.stop()
	$Player/PlayerCharacter.pause()
	$Enemy/EnemyCharacter.pause()
	for projectile in $Projectiles.get_children():
		projectile.pause()

func stop():
	$BattleMusic.stop()
	$Player/PlayerCharacter.stop()
	$Enemy/EnemyCharacter.stop()
	for projectile in $Projectiles.get_children():
		projectile.pause()

func resume():
	paused = false
	$BattleMusic.play(music_progress)
	$Player/PlayerCharacter.resume()
	$Enemy/EnemyCharacter.resume()
	for projectile in $Projectiles.get_children():
		projectile.resume()
