extends Button

export(Texture) var android_icon
export(Texture) var iphone_icon

func _ready():
	return
	icon = android_icon
	match OS.get_name():
		"Android":
			icon = android_icon
		"iOS":
			icon = iphone_icon
			
