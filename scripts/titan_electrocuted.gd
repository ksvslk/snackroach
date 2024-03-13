# titan_electrocuted_state.gd
extends TitanState

var flash_shader := load("res://shader/FlashMaterial.tres") as Resource

func enter(_msg: Dictionary = {}) -> void:
	titan.is_dead = true
	titan.z_index = 0
	titan.shader_node.material = flash_shader
	yield(get_tree().create_timer(0.1), "timeout")
	titan.shader_node.material = null
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
