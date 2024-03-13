# falling_state.gd

extends PlayerState

var move_to_center: Vector2 = Vector2(0, 0)
const SCALE_DECREASE_STEP: Vector2 = Vector2(4.0, 4.0)
const DARKEN_STEP: float = 0.7
const ANIMATION_SPEED: int = 1
const END_DESTINATION_DEVIATION: int = 30
const MOVE_TOWARDS_CENTER: int = 6
onready var audio := $Audio as AudioStreamPlayer2D

var slow_down_factor = 0.4

func enter(_msg: Dictionary = {}) -> void:
	var radians = cockroach.get_angle_to(cockroach.pit_center)
	var abs_degrees = abs(radians * (180/PI)) # for sanity let's use degrees
	var velocity_magnitude = cockroach.velocity.length_squared()
	if velocity_magnitude != 0:
		if abs_degrees >= 45: # change a bit direction when there is speed and wrong direction
			cockroach.velocity = cockroach.global_position.direction_to(cockroach.pit_center) * 300
	if velocity_magnitude == 0:
		cockroach.velocity = cockroach.global_position.direction_to(cockroach.pit_center) * 250
		slow_down_factor = 0.6
		
	cockroach.set_collision_layer_bit(0, false)
	cockroach.animation_speed = ANIMATION_SPEED
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.falling_animation)


func physics_update(_delta: float) -> void:
	if cockroach.scale.length_squared() > 0.3:
		cockroach.move_and_collide(cockroach.velocity * slow_down_factor * _delta, false)
		cockroach.scale = cockroach.scale.cubic_interpolate(cockroach.scale - SCALE_DECREASE_STEP, Vector2(0.9, 0.9), Vector2(0.6, 0.6), _delta)
		cockroach.modulate = cockroach.modulate.darkened(DARKEN_STEP * _delta)
	else:
		audio.play()
		cockroach.state_machine.transition_to(C.smashed_state)
