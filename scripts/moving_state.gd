# moving_state.gd

extends PlayerState

func enter(_msg: Dictionary = {}) -> void:
	cockroach.animation_speed = 1
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.moving_animation)


func physics_update(_delta: float) -> void:
	var collision = cockroach.move_and_collide(cockroach.velocity * _delta, false)
	if collision:
		cockroach.velocity = collision.normal * 200
		state_machine.transition_to(C.bouncing_state)


func handle_input(event: InputEvent) -> void:
	state_machine.transition_to(C.walking_state)
	Data.increase_taps()

