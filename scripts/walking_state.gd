# walking_state.gd

extends PlayerState


onready var audio := $AudioStreamPlayer as AudioStreamPlayer
const BOUNCE_SPEED_FACTOR: int = 300
const BOUNCE_DECREASE_FACTOR: float = 1.3
const ANIMATION_SPEED: int = 6
const BOUNCE_END_VELOCITY: int = 30
const DESTINATION_DEVIATION: int = 10 #70
var bouncing: bool = false
var rotation_hit_test: bool = false
var stop_time = 0.3
var _cardinal_direction: int = -1


func enter(_msg: Dictionary = {}) -> void:
	if cockroach.legs_stuck == 0:
		audio.pitch_scale = 1
		audio.volume_db = 10
		cockroach.animation_speed = ANIMATION_SPEED
	#cockroach.last_mouse_pos = get_viewport().get_mouse_position()
	cockroach.last_mouse_pos = cockroach.cursor_position
	var direction_vector: Vector2 = (cockroach.last_mouse_pos - cockroach.global_position)
	var transform_test: Transform2D = cockroach.global_transform * Transform2D().rotated(cockroach.get_angle_to(cockroach.last_mouse_pos))
	rotation_hit_test = cockroach.test_move(transform_test, Vector2(0,0), false)
	cockroach.global_transform = transform_test
	
	if cockroach.is_on_moving_platform:
		cockroach.velocity = cockroach.current_platform_velocity + direction_vector.normalized() * cockroach.walking_speed
		cockroach.last_mouse_pos += cockroach.current_platform_velocity
	else:
		cockroach.velocity = direction_vector.normalized() * cockroach.walking_speed
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.walking_animation)
	_cardinal_direction = int(4.0 * (cockroach.velocity.rotated(PI / 4.0).angle() + PI) / TAU)


func _is_over_line() -> bool:
	match _cardinal_direction:
		0, 2:  #west, east
			return abs(cockroach.global_position.x - cockroach.last_mouse_pos.x) <= DESTINATION_DEVIATION
		1, 3: # north, south
			return abs(cockroach.global_position.y - cockroach.last_mouse_pos.y) <= DESTINATION_DEVIATION
	return false
 

func adjust_walking_speed():
	var direction_vector: Vector2 = (cockroach.last_mouse_pos - cockroach.global_position)
	cockroach.velocity = direction_vector.normalized() * cockroach.walking_speed
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	if cockroach.legs_stuck >= 1:
		audio.pitch_scale = 3
		audio.volume_db = 20
	elif cockroach.legs_stuck == 0:
		audio.pitch_scale = 1
		audio.volume_db = 10


func exit() -> void:
	cockroach.last_mouse_pos = cockroach.global_position


func physics_update(_delta: float) -> void:
	var collision = cockroach.move_and_collide(cockroach.velocity * _delta, false)
	if cockroach.global_position.distance_to(cockroach.last_mouse_pos) < DESTINATION_DEVIATION or _is_over_line():
		if cockroach.is_on_moving_platform:
			cockroach.velocity = cockroach.current_platform_velocity
			state_machine.transition_to(C.moving_state)
		else:
			cockroach.velocity = Vector2(0, 0)
			state_machine.transition_to(C.idle_state)
	if collision:
		cockroach.velocity = collision.normal * 200
		state_machine.transition_to(C.bouncing_state)


func handle_input(_event: InputEvent) -> void:
	state_machine.transition_to(C.walking_state)
	Data.increase_taps()
