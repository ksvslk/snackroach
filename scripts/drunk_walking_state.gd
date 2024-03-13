# drunk_walking_state.gd

extends "res://scripts/walking_state.gd"

var drunk_dir = true
var drunk_rotation_factor = 1
var velocity_factor = 500
onready var timer = $Timer


func enter(_msg: Dictionary = {}) -> void:
	cockroach.walking_speed = cockroach.initial_walking_speed * 0.65
	velocity_factor = cockroach.initial_walking_speed.x - 140
	.enter()
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.drunk_animation)
	timer.start()


func exit() -> void:
	.exit()
	cockroach.walking_speed = cockroach.initial_walking_speed


func physics_update(_delta: float) -> void:
	cockroach.rotation += drunk_rotation_factor * _delta
	cockroach.velocity.x += velocity_factor * _delta
	.physics_update(_delta)


func handle_input(_event: InputEvent) -> void:
	if _event is InputEventScreenTouch:
		if _event.is_pressed():
			state_machine.transition_to(C.drunk_walking_state)
			Data.increase_taps()


func _on_Timer_timeout():
	drunk_rotation_factor = -drunk_rotation_factor
	velocity_factor = -velocity_factor
	timer.start()
