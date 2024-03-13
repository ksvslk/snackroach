# idle_state.gd

extends PlayerState

func enter(_msg: Dictionary = {}) -> void:
	cockroach.animation_speed = 1
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.idle_animation)


func handle_input(event: InputEvent) -> void:
	if cockroach.is_drunk:
		state_machine.transition_to(C.drunk_walking_state)
	else:
		state_machine.transition_to(C.walking_state)
	Data.increase_taps()

