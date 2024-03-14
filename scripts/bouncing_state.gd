# bouncing_state.gd

extends PlayerState
var stop_time = 0.15
var last_state := ""

func enter(_msg: Dictionary = {}) -> void:
	last_state = _msg[C.previous_state]
	cockroach.animation_speed = 1
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.bouncing_animation)


func handle_input(event: InputEvent) -> void:
	if last_state == C.drunk_walking_state:
		state_machine.transition_to(C.drunk_walking_state)
	else:
		state_machine.transition_to(C.walking_state)
	Data.increase_taps()


func physics_update(_delta: float) -> void:
	if cockroach.is_on_moving_platform:
		# decrease only the x or y depdening on which one is not ZERO
		if cockroach.current_platform_velocity.x == 0:
			cockroach.velocity = Vector2(
			cockroach.velocity.x - cockroach.velocity.x * min(_delta/stop_time, 1.0),
			cockroach.current_platform_velocity.y
			)
		else:
			cockroach.velocity = Vector2(
			cockroach.current_platform_velocity.x,
			cockroach.velocity.y - cockroach.velocity.y * min(_delta/stop_time, 1.0)
			)
	else:
		cockroach.velocity -= cockroach.velocity * min(_delta/stop_time, 1.0)
	
	if not cockroach.is_on_moving_platform and cockroach.velocity.length_squared() < 1.0:
		cockroach.velocity = Vector2(0, 0)
		cockroach.state_machine.transition_to(C.idle_state)
	elif cockroach.is_on_moving_platform and cockroach.velocity.length_squared() <= cockroach.current_platform_velocity.length_squared():
		cockroach.velocity = cockroach.current_platform_velocity
		cockroach.state_machine.transition_to(C.moving_state)
	else:
		cockroach.move_and_slide(cockroach.velocity)
