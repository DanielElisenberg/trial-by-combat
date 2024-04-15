extends Area2D

@export var length = 1.0
@export var windup = 0.0
@export var hitbox_time = 1.0
@export var hitstun_length = 0.5
@export var freeze_frame_length = 0.0
@export var damage = 10.0
@export var knockback = Vector2(0, 0)
@export var projectile: PackedScene
@export var throw_projectile: bool
@onready var hitbox = $HitBox
@onready var timer = $AttackTimer
@onready var windup_timer = $WindupTimer
@onready var hitbox_timer = $HitboxTimer
@onready var freeze_timer = $FreezeTimer
@onready var sfx = $SFX
var attacking_entity
signal attack_finished
signal send_projectile(projectile)


func _ready():
	disable()
	attacking_entity = get_parent().get_parent()


func disable():
	hitbox.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	disable_hitbox()
	timer.stop()
	windup_timer.stop()
	hitbox_timer.stop()


func initiate_attack():
	hitbox.set_deferred("process_mode", PROCESS_MODE_INHERIT)
	timer.start(length)
	if windup > 0:
		windup_timer.start(windup)
		disable_hitbox()
	else:
		enable_hitbox()

func enable_hitbox():
	sfx.play()
	if throw_projectile:
		var new_projectile = projectile.instantiate()
		new_projectile.set_position(to_global(hitbox.position))
		new_projectile.entity_sent_from = get_parent().get_parent()
		emit_signal("send_projectile", new_projectile)
	else:
		hitbox.set_deferred("disabled", false)


func pause():
	timer.set_paused(true)
	windup_timer.set_paused(true)
	hitbox_timer.set_paused(true)
	
	
func resume():
	timer.set_paused(false)
	windup_timer.set_paused(false)
	hitbox_timer.set_paused(false)


func disable_hitbox():
	hitbox.set_deferred("disabled", true)

func _on_attack_timer_timeout():
	emit_signal("attack_finished")
	disable()


func _on_body_entered(body):
	if freeze_frame_length > 0:
		attacking_entity.pause()
		body.pause()
		freeze_timer.start(freeze_frame_length)
		await freeze_timer.timeout
		attacking_entity.resume()
		body.resume()
	body.hit(attacking_entity, hitstun_length, damage, knockback)


func _on_windup_timer_timeout():
	if hitbox_time > 0:
		enable_hitbox()
		hitbox_timer.start(hitbox_time)


func _on_hitbox_timer_timeout():
	disable_hitbox()
