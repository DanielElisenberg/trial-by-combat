extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -1300.0

enum Status {IDLE, ATTACKING, STUNNED, BLOCKING, INACTIVE}

@onready var animations: AnimatedSprite2D = $Animations
@onready var hitstun_timer = $Hitstun/HitstunTimer
@onready var hitstun_SFX = $Hitstun/HitstunSFX
var status: Status = Status.INACTIVE
var pausedStatus: Status = Status.INACTIVE
var current_attack = null

var throw_combo = ["left", "down", "right", "down", "jab"]
var throw_combo_counter = 0
@onready var throw_combo_timer: Timer = $ThrowComboTimer

signal damage_taken(damage)
signal send_projectile(projectile)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var jab = $Attacks/Jab
@onready var jab_combo_timer = $Attacks/Jab/ComboTimer
var jabs_thrown = 0
var can_combo_jab = false
@onready var gavel_smash = $Attacks/GavelSmash
@onready var arial_kick = $Attacks/ArialKick
@onready var throw_gavel = $Attacks/ThrowGavel
@onready var animated_sprite = $AnimatedSprite

func _process(delta):
	if status == Status.INACTIVE:
		return
	
	if status != Status.STUNNED and status != Status.ATTACKING:
		if Input.is_action_just_pressed(throw_combo[throw_combo_counter]):
			throw_combo_counter += 1
			if throw_combo_counter == throw_combo.size():
				throw_combo_counter = 0
				throw_gavel.initiate_attack()
				animations.play("throw")
				status = Status.ATTACKING
				current_attack = throw_gavel
				throw_combo_timer.stop()
			else:
				throw_combo_timer.start()
		elif Input.is_action_just_pressed("jab") and is_on_floor():
			jab.initiate_attack()
			status = Status.ATTACKING
			current_attack = jab
			animations.play("jab")
			jab_combo_timer.start()
			jabs_thrown += 1
			can_combo_jab = false
		elif Input.is_action_just_pressed("jab") and not is_on_floor():
			arial_kick.initiate_attack()
			status = Status.ATTACKING
			current_attack = arial_kick
			animations.play("flykick")
		elif Input.is_action_just_pressed("projectile"):
			throw_gavel.initiate_attack()
			animations.play("throw")
			status = Status.ATTACKING
			current_attack = throw_gavel
	if current_attack == jab and Input.is_action_just_pressed("jab") and can_combo_jab:
		if jabs_thrown == 1:
			current_attack.disable()
			current_attack.initiate_attack()
			animations.play("jab")
			animations.set_frame_and_progress(0, 0)
			jabs_thrown += 1
			can_combo_jab = false
			jab_combo_timer.start()
		elif jabs_thrown == 2:
			current_attack.disable()
			gavel_smash.initiate_attack()
			status = Status.ATTACKING
			current_attack = gavel_smash
			animations.play("gavelsmash")
			jabs_thrown = 0
			can_combo_jab = false
		
	if current_attack == arial_kick and is_on_floor():
		current_attack.disable()
		current_attack = null
		status = Status.IDLE
		animations.play("idle")


func reset(start_position):
	if current_attack != null:
		current_attack.disable()
		current_attack = null
	status = Status.IDLE
	jabs_thrown = 0
	can_combo_jab = false
	animations.play("idle")
	velocity.x = 0
	hitstun_timer.stop()
	position = start_position


func stop():
	status = Status.INACTIVE
	hitstun_timer.stop()
	jabs_thrown = 0
	can_combo_jab = false
	animations.stop()
	if current_attack != null:
		current_attack.disable()
		current_attack = null


func pause():
	pausedStatus = status
	status = Status.INACTIVE
	hitstun_timer.set_paused(true)
	animations.pause()
	if current_attack != null:
		current_attack.pause()


func resume():
	status = pausedStatus
	hitstun_timer.set_paused(false)
	animations.play()
	if current_attack != null:
		current_attack.resume()


func _physics_process(delta):
	if status == Status.INACTIVE:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status != Status.STUNNED and (status != Status.ATTACKING or not is_on_floor()):
		
		if status != Status.BLOCKING and status != Status.ATTACKING and is_on_floor():
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * SPEED
				if status != Status.ATTACKING:
					animations.play("strafe")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if status != Status.ATTACKING:
					animations.play("idle")
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() && status != Status.ATTACKING:
			velocity.y = JUMP_VELOCITY
			status = Status.IDLE
			animations.play("jump")
			
		if Input.is_action_pressed("block") and status != Status.ATTACKING and is_on_floor():
			status = Status.BLOCKING
			velocity.x = 0
			animations.play("block")
		elif status == Status.BLOCKING:
			status = Status.IDLE
			animations.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, 75)

	move_and_slide()

func _on_attack_finished():
	can_combo_jab = false
	jabs_thrown = 0
	if status == Status.STUNNED:
		animations.play("hitstunned")
	else:
		status = Status.IDLE
		current_attack = null
		animations.play("idle")


func hit(attacker, hitstun_time, damage, knockback):
	can_combo_jab = false
	jabs_thrown = 0
	if status == Status.ATTACKING:
		current_attack.disable()
		current_attack = null
	
	if status != Status.BLOCKING:
		status = Status.STUNNED
		animations.play("hitstunned")
		hitstun_timer.start(hitstun_time)
		hitstun_SFX.play()
		emit_signal("damage_taken", damage)
		velocity = knockback
	else:
		emit_signal("damage_taken", damage / 5)


func _on_hitstun_timeout():
	animations.play("idle")
	status = Status.IDLE


func _on_send_projectile(projectile):
	emit_signal("send_projectile", projectile)


func _on_combo_timer_timeout():
	can_combo_jab = true


func _on_throw_combo_timer_timeout():
	throw_combo_counter = 0
