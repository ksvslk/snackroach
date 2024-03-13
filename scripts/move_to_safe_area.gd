extends Control

enum SafeArea {TOP, BOTTOM}
export(SafeArea) var case

func _ready():
	if OS.get_name() != "OSX":
		if case == SafeArea.TOP:
			rect_position.y += C.get_top_safe_margin()
		elif case == SafeArea.BOTTOM:
			rect_position.y -= C.get_bottom_safe_margin()

