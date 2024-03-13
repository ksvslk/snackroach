# impact.gd
class_name Impact
extends CPUParticles2D

var distance_to_roach: int = -1


func launch(pos: Vector2, target:Node2D, color_info: Color, is_protected = false, is_smashed = false, is_under_roof = false):
	global_position = pos
	# set vibration info
	if not is_smashed:
		distance_to_roach = target.global_position.distance_squared_to(global_position)
	# set color info
	_set_color(is_smashed, color_info)
	# shpw particles with effects
	if is_protected:
		emitting = false
		GPack.perform_haptic_feedback(C.soft_vibration)
	else:
		emitting = true
		GPack.perform_haptic_feedback(C.soft_vibration)


func _set_color(is_smashed: bool, color_info: Color):
	if not is_smashed:
		if color_info != Color(0,0,0,0):
			modulate.r8 = color_info.r8
			modulate.g8 = color_info.g8
			modulate.b8 = color_info.b8
	else:
		modulate.r8 = 117
		modulate.g8 = 52
		modulate.b8 = 15
