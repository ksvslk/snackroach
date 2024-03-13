# enemy_idle_state.gd

extends EnemyState
onready var timer = $Timer
var animation_speed := 1

func enter(_msg: Dictionary = {}) -> void:
	enemy.animation_player.playback_speed = animation_speed
	enemy.animation_player.play(C.idle_animation)
	timer.start()


func _on_Timer_timeout():
	if state_machine.state.name == C.idle_state and not enemy.red_light:
		enemy.agent.set_target_location(enemy.roach.global_position)
		if enemy.agent.is_target_reachable():
			state_machine.transition_to(C.walking_state)


func exit() -> void:
	timer.stop()
