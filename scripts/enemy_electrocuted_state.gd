# enemy_electrocuted_state.gd
extends EnemyState

var flash_shader := load("res://shader/FlashMaterial.tres") as Resource

func enter(_msg: Dictionary = {}) -> void:
	enemy.is_dead = true
	enemy.z_index = 0
	enemy.shader_node.material = flash_shader
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.shader_node.material = null
	enemy.circling_birds.visible = true
	enemy.actual_spider.modulate = enemy.modulate.darkened(0.3)
	enemy.set_collision_layer_bit(13, false)
	enemy.animation_player.playback_speed = 0


func exit() -> void:
	enemy.is_dead = false
	enemy.z_index = 2
	enemy.circling_birds.visible = false
	enemy.actual_spider.modulate = enemy.modulate.darkened(0)
	enemy.set_collision_layer_bit(13, true)
