extends TextureButton

func _on_MenuButton_pressed():
	if not disabled:
		#GPack.show_rewarded_ad()
		var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "modulate:a", 0.7, 0.2)
		tween.chain().tween_property(self, "modulate:a", 1.0, 0.2)
		tween.play()


func _ready():
	if OS.get_name() == "Android":
		var is_ad_already_loaded := GPack.is_rewarded_ad_loaded()
		if (is_ad_already_loaded):
			_change_button_state(is_ad_already_loaded)
		else:
			GPack.android_plugin.connect(GPack.s_rewarded_ad_loaded, self, "_rewarded_ad_loaded")


func _change_button_state(ad_loaded: bool):
	if ad_loaded:
		disabled = false
		modulate.a = 1.0
	else:
		disabled = true
		modulate.a = 0.1


func _rewarded_ad_loaded():
	_change_button_state(true)
