extends TextureButton


func _on_MenuButton_pressed():
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.7, 0.2)
	tween.chain().tween_property(self, "modulate:a", 1.0, 0.2)
	tween.play()
	
