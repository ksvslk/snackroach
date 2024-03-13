extends Button


func _ready():
	_set_texture_based_on_os()
	if GPack.android_plugin:
		set_access(GPack.is_signed_in())
		GPack.android_plugin.connect(GPack.s_on_signed_in_status_changed, self, "set_access")


func set_access(b):
	disabled = !b


func _set_texture_based_on_os():
	match OS.get_name():
		"Android":
			text = "PLAY GAMES"
			#icon = load("res://graphics/games_controller_grey.png")
		"iOS":
			text = "GAMECENTER"
			#icon = load("res://graphics/ios/game_center.png")
