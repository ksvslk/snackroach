extends CanvasLayer


onready var roach = get_parent().get_node("Roach")
onready var wall = get_parent().get_node("Wall")
const distance_factor = 1.0 / 400.0
var _labels_to_process = { }
var _label_shown_over_80_alpha = { }


func _ready():
	for child in get_children():
		if child is Label and child.has_node("Position2D"):
			_labels_to_process[child] = child.get_node("Position2D").global_position
			_label_shown_over_80_alpha[child] = false


func _process(delta):
	for label in _labels_to_process.keys():
		var pos = _labels_to_process[label]
		var dist = roach.global_position.distance_to(pos)
		var alpha = distance_factor * dist - 1.0
		if alpha < 0:
			label.modulate.a = abs(alpha)
			if label.modulate.a > 0.5:
				_label_shown_over_80_alpha[label] = true
			if _label_shown_over_80_alpha[label] and label.modulate.a < 0.1:
				label.modulate.a = 0.1
				_label_shown_over_80_alpha.erase(label)
				_labels_to_process.erase(label)

