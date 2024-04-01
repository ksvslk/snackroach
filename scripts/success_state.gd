# success_state.gd

extends PlayerState

const DESTINATION_DEVIATION: int = 50
const WALKING_SPEED: Vector2 = Vector2(170,170)
const ANIMATION_SPEED: int = 2
var points: PoolVector2Array = []


func enter(_msg: Dictionary = {}) -> void:
	cockroach.z_index = C.roach_z_index
	cockroach.set_collision_layer_bit(0, false)
	collision_shape.set_deferred("disabled", true)
	cockroach.animation_speed = ANIMATION_SPEED
	cockroach.walking_speed = WALKING_SPEED
	points = _msg["points"]
	var velocity_vector: Vector2 = (points[0] - cockroach.global_position)
	cockroach.look_at(points[0])
	cockroach.velocity = velocity_vector.normalized() * cockroach.walking_speed
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.walking_animation)
	#points.size())


func exit() -> void:
	cockroach.walking_speed = Vector2(640, 640)
	cockroach.animation_speed = 9
	cockroach.set_collision_layer_bit(0, true)
	collision_shape.set_deferred("disabled", false)
	cockroach.velocity = Vector2(0, 0)
	cockroach.animation_speed = 0


func physics_update(_delta: float) -> void:
	if not points.empty():
		cockroach.move_and_slide(cockroach.velocity)
		if cockroach.global_position.distance_squared_to(points[0]) < DESTINATION_DEVIATION:
			points.remove(0)
			if not points.empty():
				cockroach.look_at(points[0])
				cockroach.velocity = (points[0] - cockroach.global_position).normalized() * cockroach.walking_speed
			else:
				cockroach.velocity = Vector2(0, 0)
				cockroach.animation_speed = 0
				cockroach.animation_player.play(C.idle_animation)
