# scene_switcher.gd

extends ColorRect
class_name LevelSwitcher

onready var _effect_starting_level := $TweenStart as Tween
onready var _effect_ending_level := $TweenEnd as Tween
onready var _audio := $Audio as AudioStreamPlayer2D

signal start_transition_complete
signal end_transition_complete


func play_start_transition() -> void:
	_effect_starting_level.interpolate_property(self,"material:shader_param/progress",1.0,0.0,0.5)
	_effect_starting_level.start()
	_audio.play()
	yield(_effect_starting_level, "tween_completed")
	emit_signal("start_transition_complete")


func play_end_transition() -> void:
	_effect_ending_level.interpolate_property(self,"material:shader_param/progress",0.0,1.0,0.5)
	_effect_ending_level.start()
	_audio.play()
	yield(_effect_ending_level, "tween_completed")
	emit_signal("end_transition_complete")
