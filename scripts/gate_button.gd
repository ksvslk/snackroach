extends StaticBody2D
class_name GateButton

onready var _gate = get_parent().get_parent() as Gate

func toggle_button():
	_gate._toggle_gate_state(false, true)
