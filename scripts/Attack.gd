extends Area2D

@export var length = 1.0
@export var windup = 0.0
@export var hitbox_time = 1.0
@export var hitstun_length = 0.5
@export var damage = 10.0
@export var projectile: PackedScene
@export var throw_projectile: bool
@onready var hitbox = $HitBox
@onready var timer = $AttackTimer
@onready var windup_timer = $WindupTimer
@onready var hitbox_timer = $HitboxTimer
signal attack_finished
signal send_projectile(projectile)


func _ready():
	disable()


func disable():
	set_deferred("process_mode", PROCESS_MODE_DISABLED)
	set_deferred("visible", false)
	disable_hitbox()
	timer.stop()
	windup_timer.stop()
	hitbox_timer.stop()


func initiate_attack():
	set_deferred("process_mode", PROCESS_MODE_INHERIT)
	set_deferred("visible", true)
	timer.start(length)
	if windup > 0:
		windup_timer.start(windup)
		disable_hitbox()
	else:
		enable_hitbox()

func enable_hitbox():
	if throw_projectile:
		var new_projectile = projectile.instantiate()
		new_projectile.set_position(to_global(hitbox.position))
		emit_signal("send_projectile", new_projectile)
	else:
		hitbox.set_deferred("disabled", false)


func disable_hitbox():
	hitbox.set_deferred("disabled", true)

func _on_attack_timer_timeout():
	print("sending 'attack_finished' signal")
	emit_signal("attack_finished")
	disable()


func _on_body_entered(body):
	body.hit(hitstun_length, damage)


func _on_windup_timer_timeout():
	if hitbox_time > 0:
		enable_hitbox()
		hitbox_timer.start(hitbox_time)


func _on_hitbox_timer_timeout():
	disable_hitbox()
