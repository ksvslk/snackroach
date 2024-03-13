extends Light2D

export(bool) var turn_lights_on_when_finished = true
export(bool) var turn_lights_on_when_dead_for_second = false


func _ready():
	if turn_lights_on_when_finished:
		(get_parent() as Level).connect("finished", self, "set_color", [Color.white])
	if turn_lights_on_when_dead_for_second:
		(get_parent() as Level).connect("game_over", self, "add_effect")


func add_effect():
	set_color(Color.white)
	get_node("Timer").start()


func _on_Timer_timeout():
	set_color(Color.black)
