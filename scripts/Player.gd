extends "res://scripts/Wrestler.gd"

func _process(delta):
	if status != Status.STUNNED:
		if Input.is_action_just_pressed("jab") and is_on_floor():
			jab.initiate_attack()
			idle.set_deferred("visible", false)
			status = Status.ATTACKING
			current_attack = jab


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status != Status.STUNNED:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0

	move_and_slide()
