extends Button

var button_text = ""
var level_is_unlocked = false
export(Texture) var unlocked_texture 
export(Texture) var locked_texture 

func _ready():
	text = button_text
	if level_is_unlocked:
		set_button_enabled()
	else:
		set_button_disabled()


func set_button_disabled():
	icon = locked_texture
	modulate.a = 0.2
	modulate.a = 0.2
	disabled = true


func set_button_enabled():
	icon = unlocked_texture
	modulate.a = 1
	modulate.a = 1
	disabled = false
