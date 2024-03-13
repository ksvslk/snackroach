extends Sprite

export(bool) var turn_lights_on_when_finished = true
export(bool) var turn_lights_on_when_dead_for_second = false
export(float) var timer_wait_time = 0.1

onready var timer = $Timer

func _ready():
	timer.wait_time = timer_wait_time
	if turn_lights_on_when_finished:
		(get_parent() as Level).connect("finished", self, "turn_lights_on")
	if turn_lights_on_when_dead_for_second:
		(get_parent() as Level).connect("game_over", self, "add_effect")


func turn_lights_on():
	modulate.a = 0.0


func turn_lights_off():
	modulate.a = 1.0


func add_effect():
	turn_lights_on()
	timer.wait_time = timer_wait_time
	timer.start()


func _on_Timer_timeout():
	turn_lights_off()
