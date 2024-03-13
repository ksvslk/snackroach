extends TitanState

const destination_deviation: int = 50

var rotating := false

func enter(_msg: Dictionary = {}) -> void:
	go_to_next_checkpoint()
	titan.animation_player.playback_speed = titan.animation_speed
	titan.animation_player.play(C.walking_animation)


func go_to_next_checkpoint():
	var direction = titan.global_position.direction_to(titan.get_current_checkpoint())
	titan.velocity = direction * titan.walking_speed
	#titan.look_at(titan.get_current_checkpoint())


func physics_update(_delta: float) -> void:
	var current_destination = titan.get_current_checkpoint()
	var direction = current_destination - titan.global_position
	titan.global_rotation = lerp_angle(titan.global_rotation, direction.angle(), _delta * 10)
	if titan.global_position.distance_to(current_destination) < destination_deviation:
		titan.set_next_checkpoint()
		go_to_next_checkpoint()
	var collision = titan.move_and_collide(titan.velocity * _delta)
