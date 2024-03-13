extends Label


enum Result {
	MINUS,
	PAR,
	PLUS,
	SCORE
}


func play_animation(res: int):
	match res:
		Result.MINUS:
			_minus_animation()
		Result.PAR:
			_par_animation()
		Result.PLUS:
			_plus_animation()
		Result.SCORE:
			_score_animation()


func _par_animation():
	var tween = get_tree().create_tween().set_loops(1000)
	tween.tween_property(self, "custom_colors/font_color", Color.green, 0.25)
	tween.chain().tween_property(self, "custom_colors/font_color", Color.lightgreen, 0.25)
	tween.play()

	
func _minus_animation():
	var tween = get_tree().create_tween().set_loops(1000)
	tween.tween_property(self, "custom_colors/font_color", Color.blue, 0.1)
	tween.chain().tween_property(self, "custom_colors/font_color", Color.lightblue, 0.1)
	tween.play()


func _plus_animation():
	var tween = get_tree().create_tween().set_loops(1000)
	tween.tween_property(self, "custom_colors/font_color", Color.red, 0.3)
	tween.chain().tween_property(self, "custom_colors/font_color", Color.lightcoral, 0.3)
	tween.play()
	

func _score_animation():
	var tween = get_tree().create_tween().set_loops(1000)
	tween.tween_property(self, "custom_colors/font_color", Color.darkblue, 2)
	tween.chain().tween_property(self, "custom_colors/font_color", Color.lightblue, 2)
	tween.play()

