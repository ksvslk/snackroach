extends CheckButton

func _ready():
	pressed = Data.get_global_music_state()


func set_pressed_state():
	pressed = Data.get_global_music_state()


func _on_MusicButton_toggled(button_pressed):
	Data.change_global_music(button_pressed)
