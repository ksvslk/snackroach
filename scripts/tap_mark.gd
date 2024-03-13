extends Node2D


func _ready():
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(2, 2), 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(self, "queue_free")
	tween.play()
