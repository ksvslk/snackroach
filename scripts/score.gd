extends Label


var _pre_text: String = tr("score") + ": "
export(int) var current_score #100
export(int) var target_score #400
var score_increase_step = 5


func _ready():
	_set_score_increase_step()
	_display_score(current_score)


func _process(_delta: float):
	if current_score < target_score:
		var final_score: int = current_score + score_increase_step
		if final_score > target_score:
			final_score = target_score
		_display_score(final_score)


func _display_score(new_score: int):
	current_score = new_score
	text = _pre_text + String(current_score)


func set_new_target_score(new_target_score: int):
	target_score = new_target_score
	_set_score_increase_step()
	

func _set_score_increase_step() -> void:
	var difference: int = target_score - current_score
	if difference >= 500:
		score_increase_step = difference / 75
	else:
		score_increase_step = 5
