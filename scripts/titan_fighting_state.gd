# titan_fighting_state.gd
extends TitanState


func enter(_msg: Dictionary = {}) -> void:
	titan.sword.visible = true
	titan.animation_player.play(C.fighting_animation)
	titan.animation_player.playback_speed = 1
	titan.look_at(_msg["opponent_position"])
	#titan.global_position -= Vector2(50,0)
	titan.global_position += (titan.global_position - _msg["opponent_position"])/1.2


func exit() -> void:
	titan.sword.visible = false
