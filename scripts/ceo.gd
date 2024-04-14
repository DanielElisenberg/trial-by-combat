extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -400.0

enum Status {IDLE, ATTACKING, STUNNED, BLOCKING, INACTIVE}

@onready var animations: AnimatedSprite2D = $Animations
@onready var hitstun_timer = $Hitstun/HitstunTimer
@onready var hitstun_sfx = $Hitstun/HitstunSFX
var status: Status = Status.INACTIVE
var current_attack = null

signal damage_taken(damage)
signal send_projectile(projectile)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var bump = $Attacks/Bump
@onready var throw_money = $Attacks/ThrowMoney
@onready var animated_sprite: AnimatedSprite2D = $Animations
@onready var attack_timer = $AttackTimer
@onready var strafe_timer = $StrafeTimer
var direction = 0


func _on_attack_timer_timeout():
	if status == Status.INACTIVE:
		return
	if status == Status.IDLE:
		initiate_throw_money()
	else:
		attack_timer.start(randf_range(0.1, 0.5))


func initiate_throw_money():
	throw_money.initiate_attack()
	animated_sprite.play("throw")
	status = Status.ATTACKING
	current_attack = throw_money
	attack_timer.start(randf_range(1.0, 2.0))


func initiate_bump():
	bump.initiate_attack()
	animated_sprite.play("bump")
	status = Status.ATTACKING
	current_attack = bump
	attack_timer.start(randf_range(current_attack.length, 3))

func reset(start_position):
	if current_attack != null:
		current_attack.disable()
		current_attack = null
	status = Status.IDLE
	animations.play("idle")
	velocity.x = 0
	hitstun_timer.stop()
	attack_timer.start()
	strafe_timer.start()
	direction = 0
	position = start_position

func stop():
	if current_attack != null:
		current_attack.disable()
		current_attack = null
	animations.stop()
	status = Status.INACTIVE
	velocity.x = 0
	hitstun_timer.stop()
	attack_timer.stop()
	strafe_timer.stop()
	direction = 0
	

func _on_strafe_timer_timeout():
	direction = randi_range(-1, 1)
	strafe_timer.start(randf_range(0.5, 2))


func _physics_process(delta):
	if status == Status.INACTIVE:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status == Status.IDLE:
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("strafe")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	elif status == Status.ATTACKING:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif status == Status.STUNNED:
		velocity.x = move_toward(velocity.x, 0, 75)
	elif status == Status.BLOCKING:
		velocity.x = 0
	
	if status == Status.STUNNED:
		animated_sprite.play("hitstunned")
		
	move_and_slide()

func _on_attack_finished():
	if status == Status.STUNNED:
		animations.play("hitstunned")
	elif status != Status.BLOCKING:
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
	else:
		emit_signal("damage_taken", damage / 5)
		$BlockTimer.stop()
		initiate_bump()


func _on_hitstun_timeout():
	if current_attack != null:
		current_attack.disable()
		current_attack = null
	animations.play("block")
	status = Status.BLOCKING
	$BlockTimer.start(randf_range(0.5, 1.5))


func _on_send_projectile(projectile):
	emit_signal("send_projectile", projectile)


func _on_block_timer_timeout():
	initiate_throw_money()
