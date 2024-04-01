extends Button

export(Texture) var regular_icon
var rainbow_effect = load("res://styles/RainbowShader.tres")

func _ready():
	if text != "":
		visible = true
		
		
func _set(property, value):
	if property == "text" and value != "":
		#"Setting text: ", value)
		visible = true


func add_rainbow_effect():
	material = rainbow_effect
	
	
func remove_rainbow_effect():
	material = null
