extends VBoxContainer

onready var music_button = $MusicButton
onready var sound_button = $SoundButton
onready var haptic_feedback_button = $HapticFeedbackButton

func _set(property, value):
	if property == "visible" and value == true:
		music_button.set_pressed_state()
		sound_button.set_pressed_state()
		haptic_feedback_button.set_pressed_state()
		visible = value
