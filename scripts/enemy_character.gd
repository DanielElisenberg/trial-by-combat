extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -400.0

enum Status {IDLE, ATTACKING, STUNNED, BLOCKING}

@onready var animations: AnimatedSprite2D = $Animations
@onready var hitstun_timer = $Hitstun/HitstunTimer
@onready var hitstun_sfx = $Hitstun/HitstunSFX
var status: Status = Status.IDLE
var current_attack = null

signal damage_taken(damage)
signal send_projectile(projectile)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var jab = $Attacks/Jab
@onready var throw_fireball = $Attacks/ThrowFireball
@onready var kick = $Attacks/Kick
@onready var animated_sprite: AnimatedSprite2D = $Animations
@onready var attack_timer = $AttackTimer
@onready var strafe_timer = $StrafeTimer
var direction = 0


func _on_attack_timer_timeout():
	if status != Status.STUNNED:
		var random_attack = randi_range(0, 2)
		if random_attack == 0:
			throw_fireball.initiate_attack()
			animated_sprite.play("throw")
			status = Status.ATTACKING
			current_attack = throw_fireball
		elif random_attack == 1:
			jab.initiate_attack()
			animated_sprite.play("jab")
			status = Status.ATTACKING
			current_attack = jab
		elif random_attack == 2:
			kick.initiate_attack()
			animated_sprite.play("kick")
			status = Status.ATTACKING
			current_attack = kick
		attack_timer.start(randf_range(current_attack.length, 3))
	else:
		attack_timer.start(randf_range(0.1, 1))


func _on_strafe_timer_timeout():
	direction = randi_range(-1, 1)
	strafe_timer.start(randf_range(0.5, 2))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status != Status.STUNNED and status != Status.ATTACKING:
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("strafe")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	elif status == Status.ATTACKING:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, 75)
	
	if status == Status.STUNNED:
		animated_sprite.play("hitstunned")
		
	move_and_slide()

func _on_attack_finished():
	if status == Status.STUNNED:
		animations.play("hitstunned")
	else:
		status = Status.IDLE
		current_attack = null
		animations.play("idle")


func hit(hitstun_time, damage, knockback):
	if status == Status.ATTACKING:
		current_attack.disable()
		current_attack = null
	
	if status != Status.BLOCKING:
		status = Status.STUNNED
		animations.play("hitstunned")
		hitstun_timer.start(hitstun_time)
		emit_signal("damage_taken", damage)
		hitstun_sfx.play()
		velocity = knockback
	
	emit_signal("damage_taken", damage / 5)


func _on_hitstun_timeout():
	animations.play("idle")
	status = Status.IDLE


func _on_send_projectile(projectile):
	emit_signal("send_projectile", projectile)
