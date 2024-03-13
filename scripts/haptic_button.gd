extends CheckButton


func _ready():
	pressed = Data.get_haptic_feedback_state()


func set_pressed_state():
	pressed = Data.get_haptic_feedback_state()


func _on_HapticFeedbackButton_toggled(button_pressed):
	Data.change_haptic_feedback(button_pressed)
