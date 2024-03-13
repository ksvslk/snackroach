extends CenterContainer

onready var level_info_text = $LevelInfoText
onready var info_shown = $InfoShown

func set_info_and_display(par: int):
	var info = tr("par") + ": " + str(par)
	level_info_text.text = info
	_animate_info_text_in()


func _animate_info_text_in():
	var tween = get_tree().create_tween()
	tween.tween_property(level_info_text, "modulate:a", 1.0, 0.25)
	tween.tween_callback(info_shown, "start")
	tween.play()


func _animate_info_text_out():
	var tween = get_tree().create_tween()
	tween.tween_property(level_info_text, "modulate:a", 0.0, 0.25)
	tween.play()


func _on_InfoShown_timeout():
	_animate_info_text_out()
