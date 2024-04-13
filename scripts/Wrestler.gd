extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var jab = $Attacks/Jab
@onready var idle = $Idle
@onready var hitstun = $Hitstun
@onready var hitstun_timer = $Hitstun/HitstunTimer

signal damage_taken(damage)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _on_attack_finished():
	idle.set_deferred("visible", true)


func hit(hitstun_time, damage):
	hitstun.set_deferred("visible", true)
	idle.set_deferred("visible", false)
	hitstun_timer.stop()
	hitstun_timer.wait_time = hitstun_time
	hitstun_timer.start()
	emit_signal("damage_taken", damage)


func _on_hitstun_timer_timeout():
	hitstun.set_deferred("visible", false)
	idle.set_deferred("visible", true)
