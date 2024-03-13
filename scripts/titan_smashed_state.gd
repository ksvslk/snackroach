extends TitanState

func enter(_msg: Dictionary = {}) -> void:
	$AudioStreamPlayer2D.play()
	titan.is_dead = true
	titan.z_index = 0
	titan.circling_birds.visible = true
	titan.actual_titan_beetle.modulate = titan.modulate.darkened(0.3)
	titan.set_collision_layer_bit(13, false)
	titan.animation_player.playback_speed = 0


func exit() -> void:
	titan.is_dead = false
	titan.z_index = 2
	titan.circling_birds.visible = false
	titan.actual_titan_beetle.modulate = titan.modulate.darkened(0)
	titan.set_collision_layer_bit(13, true)
