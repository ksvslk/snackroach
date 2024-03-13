# enemy_smashed_state.gd
extends EnemyState

func enter(_msg: Dictionary = {}) -> void:
	enemy.is_dead = true
	enemy.z_index = 0
	enemy.circling_birds.visible = true
	enemy.actual_spider.modulate = enemy.modulate.darkened(0.3)
	enemy.set_collision_layer_bit(13, false)
	enemy.animation_player.playback_speed = 0
	#enemy.animation_player.play(C.smashed_animation)
	if enemy.pit_center and state_machine.state.name != C.smashed_state:
		state_machine.transition_to(C.falling_state)


func exit() -> void:
	enemy.is_dead = false
	enemy.z_index = 2
	enemy.circling_birds.visible = false
	enemy.actual_spider.modulate = enemy.modulate.darkened(0)
	enemy.set_collision_layer_bit(13, true)
