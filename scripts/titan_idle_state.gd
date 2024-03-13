extends TitanState


func enter(_msg: Dictionary = {}) -> void:
	titan.animation_player.playback_speed = titan.animation_speed
	titan.animation_player.play(C.idle_animation)
	titan.state_machine.transition_to(C.walking_state)
