extends Node2D
class_name Gate, "res://graphics/icons/gate_node.svg"

onready var button := $ButtonArea as Area2D
onready var audio_switch := $Switch as AudioStreamPlayer2D
export var is_gate_closed := true
export var growth_time := 0.5
export var switch_on_roof := false
onready var switch_glow = $ButtonArea/SwitchGlow
onready var gate = $Gate
onready var open_close = $OpenClose

export var path_to_navigation_polygon := NodePath()
onready var nav_polygon = null

export(Array, NodePath) var affected_gates

var _busy: bool = false


func _ready():
	if switch_on_roof:
		button.z_index = C.switch_on_roof_z_index
		get_node("Line2D").z_index = C.switch_on_roof_z_index
	if path_to_navigation_polygon:
		nav_polygon = get_node(path_to_navigation_polygon) as NavigationPolygonInstance
	if is_gate_closed:
		_close_door()
	else:
		_open_door()


func switch_other_gates() -> bool:
	var all_gates_not_busy = true
	for path in affected_gates:
		if (get_node(path) as Gate)._busy:
			all_gates_not_busy = false
			break
	if all_gates_not_busy:
		for path in affected_gates:
			(get_node(path) as Gate)._toggle_gate_state(true)
	return all_gates_not_busy


func _open_door():
	open()
	switch_glow.turn_off()
	#if nav_polygon:
		#nav_polygon.enabled = true
	_change_collision_to(false)


func _close_door():
	close()
	switch_glow.turn_on()
	if nav_polygon:
		nav_polygon.enabled = false


func _change_collision_to(flag: bool) -> void:
	gate.set_collision_layer_bit(3, flag)
	gate.set_collision_mask_bit(13, flag)
	gate.set_collision_mask_bit(0, flag)
 

func _toggle_gate_state(no_audio: bool = false, recursive: bool = false):
	if not _busy:
		var other_gates_are_not_busy = true
		if recursive:
			other_gates_are_not_busy = switch_other_gates()
		if other_gates_are_not_busy:
			if is_gate_closed:
				is_gate_closed = false
				_open_door()
			else:
				is_gate_closed = true
				_close_door()
			if not no_audio:
				open_close.play()
				audio_switch.play()
		

func close() -> void:
	_busy = true
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(gate, "scale:x", 1.0, .1)
	tween.tween_callback(self, "_set_not_busy", [true])
	tween.play()


func open() -> void:
	_busy = true
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(gate, "scale:x", 0.05, .2)
	tween.tween_callback(self, "_set_not_busy", [false])
	tween.play()


func _set_not_busy(flag: bool):
	if flag:
		_change_collision_to(flag)
	if not is_gate_closed:
		if nav_polygon:
			nav_polygon.enabled = true
	_busy = false


func _on_ButtonArea_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if switch_on_roof and area.name == "Cockroach" and area.get_parent().is_on_roof:
		_toggle_gate_state(false, true)
	elif area.name == "Cockroach" and not switch_on_roof:
		_toggle_gate_state(false, true)

