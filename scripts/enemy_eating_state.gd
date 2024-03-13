extends EnemyState


var cockroach_catched = false
var attack_speed = Vector2(500, 500)
onready var audio_stream_player_2d = $AudioStreamPlayer2D
	
	
func enter(_msg: Dictionary = {}) -> void:
	enemy.z_index = C.enemy_eating_z_index
	enemy.set_collision_layer_bit(13, false)
	enemy.animation_player.playback_speed = 5
	enemy.animation_player.play(C.walking_animation)
	enemy.look_at(enemy.roach.global_position)
	audio_stream_player_2d.play()

	
func physics_update(_delta: float) -> void:
	if not cockroach_catched:
		var direction = enemy.global_position.direction_to(enemy.roach.global_position)
		var velocity = direction * attack_speed
		var collision = enemy.move_and_collide(velocity * _delta)
		if enemy.global_position.distance_to(enemy.roach.global_position) < 10:
			cockroach_catched = true
			enemy.animation_player.playback_speed = 1
			enemy.animation_player.play(C.eating_animation)
		

func exit() -> void:
	enemy.set_collision_layer_bit(13, true)
