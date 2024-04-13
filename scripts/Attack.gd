extends Area2D

@export var length = 1.0
@export var hitstun_length = 0.5
@export var damage = 10.0
@onready var timer = $AttackTimer
signal attack_finished


func _ready():
	disable()
	timer.wait_time = length


func _process(delta):
	pass


func disable():
	set_deferred("process_mode", PROCESS_MODE_DISABLED)
	set_deferred("visible", false)
	timer.stop()


func initiate_attack():
	set_deferred("process_mode", PROCESS_MODE_INHERIT)
	set_deferred("visible", true)
	timer.start()

func _on_attack_timer_timeout():
	disable()
	emit_signal("attack_finished")


func _on_body_entered(body):
	body.hit(hitstun_length, damage)
