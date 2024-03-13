extends Node

export var rock_thrower_path := NodePath()
onready var rock_thrower = get_node(rock_thrower_path)


func _on_Beam_beam_was_deactivated():
	rock_thrower.throwing_enabled = true
	rock_thrower.start_throwing()
	

func _on_Beam_beam_was_activated():
	rock_thrower.stop_throwing()
