# jump_state.gd

extends PlayerState

const PREVIOUS_WALKING_JUMP_SPEED:int = 700
var default_jump_speed: int = 450

func enter(_msg:Dictionary = {}) -> void:
	if _msg.get(C.state_before_prepare) == C.walking_state:
		default_jump_speed = PREVIOUS_WALKING_JUMP_SPEED
		cockroach.animation_speed = 1
	cockroach.set_collision_mask_bit(C.ROOF_BIT, false)
	cockroach.animation_player.playback_speed = cockroach.animation_speed
	cockroach.animation_player.play(C.jump_animation)


func exit() -> void:
	cockroach.animation_speed = 1
	default_jump_speed = 450
	if not cockroach.is_on_roof:
		cockroach.set_collision_mask_bit(C.ROOF_BIT, true)
		cockroach.z_index = C.roach_z_index
		

func physics_update(_delta: float) -> void:
	if cockroach.animation_player.is_playing():
		cockroach.move_and_slide(cockroach.transform.x * default_jump_speed)
	else:
		state_machine.transition_to(C.idle_state)
	var collision := cockroach.get_last_slide_collision() as KinematicCollision2D
	if collision:
		state_machine.transition_to(C.abrupt_stop_jump_state)
