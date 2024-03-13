extends Node2D

func _input(event):
	if event is InputEventSingleScreenSwipe:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 0.25)
		tween.tween_callback(self, "_free_me")
		tween.play()


func _free_me():
	queue_free()
