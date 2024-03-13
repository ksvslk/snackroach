extends TitanState


var cockroach_catched = false
var attack_speed = Vector2(500, 500)
onready var audio_stream_player_2d = $AudioStreamPlayer2D
	
	
func enter(_msg: Dictionary = {}) -> void:
	titan.z_index = C.enemy_eating_z_index
	titan.set_collision_layer_bit(13, false)
	titan.animation_player.playback_speed = 5
	titan.animation_player.play(C.walking_animation)
	titan.look_at(titan.roach.global_position)
	audio_stream_player_2d.play()


func physics_update(_delta: float) -> void:
	if not cockroach_catched:
		var direction := titan.global_position.direction_to(titan.roach.global_position)
		var velocity = direction * attack_speed
		titan.move_and_collide(velocity * _delta)
		if titan.global_position.distance_to(titan.roach.global_position) < 100:
			cockroach_catched = true
			titan.animation_player.playback_speed = 1
			titan.animation_player.play(C.eating_animation)
		

func exit() -> void:
	titan.set_collision_layer_bit(13, true)
