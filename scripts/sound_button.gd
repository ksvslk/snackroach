extends CheckButton


func _ready():
	pressed = Data.get_global_sound_state()


func set_pressed_state():
	pressed = Data.get_global_sound_state()


func _on_SoundButton_toggled(button_pressed):
	Data.change_global_sound(button_pressed)
	
