# smashed_state.gd

extends PlayerState

onready var audio := $Audio as AudioStreamPlayer2D
var bouncing = false

func enter(_msg: Dictionary = {}) -> void:
	#print("SMASHED!")
	var roach_body := cockroach.get_node("CockWrapper/Cockroach") as Node2D
	audio.play()
	cockroach.circling_birds.visible = true
	roach_body.modulate = cockroach.modulate.darkened(0.3)
	cockroach.set_collision_layer_bit(0, false)
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	if cockroach.is_on_moving_platform:
		cockroach.animation_player.play(C.smashed_conveyer_animation)
	else:
		cockroach.animation_player.play(C.smashed_animation)


func exit() -> void:
	audio.stop()
	cockroach.circling_birds.visible = false
	var roach_body := cockroach.get_node("CockWrapper/Cockroach") as Node2D
	roach_body.modulate = cockroach.modulate.darkened(0)
	cockroach.set_collision_layer_bit(0, true)
	
