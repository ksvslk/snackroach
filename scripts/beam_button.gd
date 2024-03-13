extends StaticBody2D
class_name BeamButton

onready var _beam = get_parent().get_parent() as Beam

func toggle_button():
	_beam._toggle_laser_state()
