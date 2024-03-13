extends Label

var original_color = Color()
var style_box = null
var tween = null

func _ready():
	style_box = self.get_stylebox("normal") as StyleBoxFlat
	original_color = style_box.bg_color

func start_flashing():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_loops(1000)
	tween.tween_property(style_box, "bg_color", Color.gray, 1)
	tween.tween_property(style_box, "bg_color", original_color, 1)
	

func stop_flashing():
	if tween:
		tween.kill()
		tween.queue_free()
