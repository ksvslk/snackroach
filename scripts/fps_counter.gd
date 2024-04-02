extends Label

export(bool) var enable_fps = false

func _process(_delta: float) -> void:
	if enable_fps:
		set_text(String(Engine.get_frames_per_second()))
	else:
		visible = false
