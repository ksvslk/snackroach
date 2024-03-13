# enemy_fighting_state.gd
extends EnemyState


func enter(_msg: Dictionary = {}) -> void:
	enemy.sword.visible = true
	enemy.animation_player.play(C.fighting_animation)
	enemy.animation_player.playback_speed = 1
	enemy.look_at(_msg["opponent_position"])
	##print(enemy.global_position - _msg["opponent_position"])
	#enemy.global_position -= (enemy.global_position - _msg["opponent_position"])/1.5
	
	
func exit() -> void:
	enemy.sword.visible = false
