extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum Status {IDLE, ATTACKING, STUNNED, BLOCKING}

@onready var animations: AnimatedSprite2D = $Animations
@onready var hitstun_timer = $Hitstun
var status: Status = Status.IDLE
var current_attack = null

signal damage_taken(damage)
signal send_projectile(projectile)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var jab = $Attacks/Jab
@onready var throw_gavel = $Attacks/ThrowGavel
@onready var animated_sprite = $AnimatedSprite

func _process(delta):
	if status != Status.STUNNED and status != Status.ATTACKING:
		if Input.is_action_just_pressed("jab") and is_on_floor():
			jab.initiate_attack()
			status = Status.ATTACKING
			current_attack = jab
			animations.play("jab")
		elif Input.is_action_just_pressed("projectile"):
			throw_gavel.initiate_attack()
			animations.play("throw")
			status = Status.ATTACKING
			current_attack = throw_gavel


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status != Status.STUNNED:
		
		if status != Status.BLOCKING && is_on_floor():
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
		velocity.x = 0

	move_and_slide()

func _on_attack_finished():
	if status == Status.STUNNED:
		animations.play("hitstunned")
	else:
		status = Status.IDLE
		current_attack = null
		animations.play("idle")


func hit(hitstun_time, damage):
	if status == Status.ATTACKING:
		current_attack.disable()
		current_attack = null
	
	if status != Status.BLOCKING:
		status = Status.STUNNED
		animations.play("hitstunned")
		hitstun_timer.start(hitstun_time)
		emit_signal("damage_taken", damage)


func _on_hitstun_timeout():
	animations.play("idle")
	status = Status.IDLE


func _on_send_projectile(projectile):
	emit_signal("send_projectile", projectile)
