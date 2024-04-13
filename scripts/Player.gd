extends "res://scripts/Wrestler.gd"

@onready var jab = $Attacks/Jab
@onready var throw_gavel = $Attacks/ThrowGavel

func _process(delta):
	if status != Status.STUNNED and status != Status.ATTACKING:
		if Input.is_action_just_pressed("jab") and is_on_floor():
			jab.initiate_attack()
			idle.set_deferred("visible", false)
			status = Status.ATTACKING
			current_attack = jab
		elif Input.is_action_just_pressed("projectile"):
			throw_gavel.initiate_attack()
			idle.set_deferred("visible", false)
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
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() && status != Status.ATTACKING:
			velocity.y = JUMP_VELOCITY
			status = Status.IDLE
			idle.set_deferred("visible", true)
			blocking_sprite.set_deferred("visible", false)
			
		if Input.is_action_pressed("block") and status != Status.ATTACKING and is_on_floor():
			status = Status.BLOCKING
			velocity.x = 0
			idle.set_deferred("visible", false)
			blocking_sprite.set_deferred("visible", true)
		elif status == Status.BLOCKING:
			status = Status.IDLE
			idle.set_deferred("visible", true)
			blocking_sprite.set_deferred("visible", false)
	else:
		velocity.x = 0

	move_and_slide()
