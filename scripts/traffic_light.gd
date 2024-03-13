class_name TrafficLight
extends Node2D

enum CurrentLight {
	RED,
	GREEN,
	PAUSE
}

export var path_to_player := NodePath()
export(CurrentLight) var current_light = CurrentLight.RED
export(float) var red_light_seconds = 1
export(float) var green_light_seconds = 2

onready var green_light = $GreenLight
onready var red_light = $RedLight
onready var light_timer = $LightTimer
onready var roach := get_node(path_to_player) as KinematicCockroach
onready var switch = $Switch
onready var electrocuted = $Electrocuted

var roach_electrocuted := false

signal red_light
signal green_light


func _ready():
	if current_light == CurrentLight.RED:
		green_light.modulate.a = 0.05
		red_light.modulate.a = 1.0
		light_timer.wait_time = red_light_seconds
		emit_signal("red_light")
	elif current_light == CurrentLight.GREEN:
		green_light.modulate.a = 1.0
		red_light.modulate.a = 0.05
		light_timer.wait_time = green_light_seconds
		emit_signal("green_light")
	light_timer.start()


func _set_timer_for_next_cycle():
	if current_light == CurrentLight.RED:
		current_light = CurrentLight.GREEN
		red_light.modulate.a = 0.05
		green_light.modulate.a = 1.0
		light_timer.wait_time = green_light_seconds
		emit_signal("green_light")
	elif current_light == CurrentLight.GREEN:
		current_light = CurrentLight.RED
		red_light.modulate.a = 1.0
		green_light.modulate.a = 0.05
		light_timer.wait_time = red_light_seconds
		emit_signal("red_light")


func _physics_process(delta:float):
	if not roach_electrocuted and roach.state_machine.state.name == C.walking_state and current_light == CurrentLight.RED:
		roach_electrocuted = true
		electrocuted.play()
		roach.electrocute()


func _on_LightTimer_timeout():
	_set_timer_for_next_cycle()
	light_timer.start()
	switch.play()
