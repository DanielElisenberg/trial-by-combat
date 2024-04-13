extends "res://scripts/Wrestler.gd"

@onready var attack = $Attacks/Attack
@onready var attack_timer = $AttackTimer
@onready var strafe_timer = $StrafeTimer
var direction = 0

func _on_attack_timer_timeout():
	if status != Status.STUNNED:
		attack.initiate_attack()
		idle.set_deferred("visible", false)
		status = Status.ATTACKING
		current_attack = attack
	attack_timer.start(randf_range(0.5, 2))


func _on_strafe_timer_timeout():
	direction = randi_range(-1, 1)
	strafe_timer.start(randf_range(0.5, 2))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if status != Status.STUNNED:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0
	move_and_slide()
