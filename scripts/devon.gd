extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -1200.0
const active_time = 10
const exhausted_time = 7

enum Status {IDLE, ATTACKING, STUNNED, BLOCKING, AIRBORNE, INACTIVE}

@onready var animations: AnimatedSprite2D = $Animations
@onready var hitstun_timer = $Hitstun/HitstunTimer
@onready var hitstun_sfx = $Hitstun/HitstunSFX
var status: Status = Status.INACTIVE
var paused_status: Status = Status.INACTIVE
var current_attack = null
var exhausted = false

signal damage_taken(damage)
signal send_projectile(projectile)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var spin_kick = $Attacks/SpinKick
@onready var throw_vape = $Attacks/ThrowVape
@onready var jump_kick = $Attacks/JumpKick
@onready var animated_sprite: AnimatedSprite2D = $Animations
@onready var attack_timer = $AttackTimer
@onready var strafe_timer = $StrafeTimer
var direction = -1
var collided_with_wall = false


func _on_attack_timer_timeout():
	if status == Status.INACTIVE:
		return
	if status == Status.IDLE and is_on_floor():
		var random_attack = randi_range(0, 3)
		if random_attack == 0:
			initiate_throw()
		elif random_attack > 0 and not exhausted:
			initiate_spin_kick()
		elif exhausted:
			attack_timer.start(randf_range(0.5, 1))
	else:
		attack_timer.start(randf_range(0.1, 0.5))


func initiate_spin_kick():
	spin_kick.initiate_attack()
	animated_sprite.play("spinkick")
	status = Status.ATTACKING
	current_attack = spin_kick
	attack_timer.start(randf_range(current_attack.length, 1))


func initiate_throw():
	throw_vape.initiate_attack()
	animated_sprite.play("throw")
	status = Status.ATTACKING
	current_attack = throw_vape
	attack_timer.start(randf_range(current_attack.length, 1))


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


func pause():
	paused_status = status
	status = Status.INACTIVE
	hitstun_timer.set_paused(true)
	attack_timer.set_paused(true)
	strafe_timer.set_paused(true)
	$JumpTimer.set_paused(true)
	animations.pause()
	if current_attack != null:
		current_attack.pause()


func resume():
	status = paused_status
	hitstun_timer.set_paused(false)
	attack_timer.set_paused(false)
	strafe_timer.set_paused(false)
	$JumpTimer.set_paused(false)
	animations.play()
	if current_attack != null:
		current_attack.resume()


func _on_strafe_timer_timeout():
	direction = randi_range(-1, 1)
	if direction == 0 and not exhausted:
		direction = randi_range(0, 1)
		if direction == 0:
			direction = -1
	strafe_timer.start(randf_range(0.5, 1))


func _physics_process(delta):
	print(is_on_wall())
	if status == Status.INACTIVE:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall() and not collided_with_wall:
		direction * -1
	collided_with_wall = is_on_wall()

	if current_attack == jump_kick and is_on_floor():
		jump_kick.disable()
		initiate_spin_kick()
	elif status == Status.AIRBORNE and is_on_floor() and velocity.y >= 0:
		status = Status.IDLE
		animations.play("idle")
	if status != Status.STUNNED and status != Status.AIRBORNE:
		var current_speed = SPEED
		if exhausted:
			current_speed /= 2
		if direction:
			velocity.x = direction * current_speed
			if status == Status.IDLE:
				animated_sprite.play("strafe")
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			if status == Status.IDLE:
				animated_sprite.play("idle")
	elif status == Status.STUNNED:
		velocity.x = move_toward(velocity.x, 0, 75)
	elif status == Status.AIRBORNE and velocity.y > 0 and not exhausted:
		jump_kick.initiate_attack()
		animated_sprite.play("jumpkick")
		current_attack = jump_kick
	
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


func hit(attacker, hitstun_time, damage, knockback):
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
	initiate_spin_kick()


func _on_send_projectile(projectile):
	emit_signal("send_projectile", projectile)


func _on_jump_timer_timeout():
	if status == Status.IDLE:
		status = Status.AIRBORNE
		velocity.y = JUMP_VELOCITY
		if exhausted:
			velocity.y /= 2
		animations.play("jump")


func _on_exhaustion_timer_timeout():
	if exhausted:
		exhausted = false
		$ExhaustionTimer.start(active_time)
	else:
		exhausted = true
		$ExhaustionTimer.start(exhausted_time)
