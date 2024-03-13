# level_scene.gd

extends Node2D
class_name Level


onready var roach := $Roach
onready var success_point := $Roof/SuccessPoint as Position2D
onready var final_point := $Roof/FinalPoint as Position2D
onready var rock_thrower := $RockThrower
onready var snacks := $Snack/Snacks as Snacks

export(int) var par
export(int) var max_taps
export(int) var rewarded_taps_amount

const luminosity_while_on_roof: float = 0.2

signal game_over
signal finished

var tapping_enabled = true

func _ready():
	roach.connect("foodgate_touched", self, "_roach_made_it_to_the_food_gate")
	if OS.is_debug_build():
		assert(par != 0)
	_init_roofs_connections()
	rock_thrower.start_throwing()


func init_snacks() -> void:
	snacks.init_snacks(par)


func _init_roofs_connections():
	var roofs: Array = get_tree().get_nodes_in_group(C.roofs_group)
	for roof in roofs:
		roof.connect("body_shape_entered", self, "_on_Roofs_body_shape_entered")
		roof.connect("body_shape_exited", self, "_on_Roofs_body_shape_exited")


func _on_Roofs_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	roach.modulate.v = 0.7
	roach.is_under_roof = true


func _on_Roofs_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	roach.modulate.v = 1
	roach.is_under_roof = false


func get_current_state() -> String:
	return roach.state_machine.state.name


func is_shield_activated() -> bool:
	return roach.shield_activated
	

func activate_shield() -> void:
	roach.activate_shield()


func restart():
	tapping_enabled = true
	roach.foodgate_reached = false
	roach.global_position = roach.starting_position
	roach.global_rotation = roach.starting_rotation
	roach.state_machine.transition_to(C.idle_state)
	get_tree().call_group("RestorableTilemap", "restore_original_tiles")
	rock_thrower.start_throwing()


func _on_Roach_dead():
	GPack.perform_haptic_feedback(C.fail_vibration)
	emit_signal("game_over")
	rock_thrower.stop_throwing()


func _roach_made_it_to_the_food_gate():
	snacks.eat_all_snacks()
	rock_thrower.stop_throwing()
	roach.state_machine.transition_to(C.success_State, {"points":[success_point.global_position, final_point.global_position]})
	GPack.perform_haptic_feedback(C.success_vibration)
	emit_signal("finished")


onready var m:Vector2 = get_global_mouse_position()


func _physics_process(delta):
	var velocity = Input.get_vector("l", "r", "u", "d")
	var movement = 1300.0 * velocity * delta
	if (movement):
		var final_pos = Vector2(m.x, m.y) + movement
		get_viewport().warp_mouse(final_pos)
		m = final_pos


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if event is InputEventMouseButton && tapping_enabled:
			print("Mouse click")
			roach.cursor_position = get_global_mouse_position()
			roach.state_machine.state.handle_input(event)
			#var tap_mark = load("res://scenes/TapMark.tscn").instance()
			#add_child(tap_mark)
			#tap_mark.set("global_position", roach.cursor_position)
			GPack.perform_haptic_feedback(C.tap_vibration)
		elif event is InputEventJoypadButton && tapping_enabled:
			print("Joy button click")
			roach.cursor_position = m
			roach.state_machine.state.handle_input(event)
			#var tap_mark = load("res://scenes/TapMark.tscn").instance()
			#add_child(tap_mark)
			#tap_mark.set("global_position", roach.cursor_position)
			GPack.perform_haptic_feedback(C.tap_vibration)
	
