extends Node2D
class_name Beam, "res://graphics/icons/beam_node.svg"

onready var tween := $LaserArea/Tween as Tween
onready var button := $ButtonArea as Area2D
onready var audio_switch := $Switch as AudioStreamPlayer2D
onready var audio_electro := $Electrocuted as AudioStreamPlayer2D
onready var beam := $LaserArea/Laser
export var is_laser_activated := true
export var growth_time := 0.5
export var switch_on_roof := false
onready var laser_area2d = $LaserArea as Area2D
onready var switch_glow = $ButtonArea/SwitchGlow
onready var glow1 = $LaserArea/Laser/EndPortal/Glow
onready var glow2 = $LaserArea/Laser/StartPortal/Glow

export var path_to_navigation_polygon := NodePath()
onready var nav_polygon = null

signal beam_was_deactivated
signal beam_was_activated

export(Array, NodePath) var affected_lasers

func _ready():
	if switch_on_roof:
		button.z_index = C.switch_on_roof_z_index
		get_node("Line2D").z_index = C.switch_on_roof_z_index
	if path_to_navigation_polygon:
		nav_polygon = get_node(path_to_navigation_polygon) as NavigationPolygonInstance
	if is_laser_activated:
		_execute_laser_activation()
	else:
		_execute_laser_deactivation()


func switch_other_lasers() -> void:
	for laser_path in affected_lasers:
		(get_node(laser_path) as Beam)._toggle_laser_state(true, false)


func _execute_laser_deactivation():
	disappear()
	switch_glow.turn_off()
	#button_sprite.frame = 1
	#laser_area2d.set_collision_mask_bit(12, 0)
	laser_area2d.set_deferred("monitorable", false)
	laser_area2d.set_deferred("monitoring", false)
	if nav_polygon:
		nav_polygon.enabled = true
	#emit_signal("beam_was_deactivated")
	call_deferred("emit_signal", "beam_was_deactivated")


func _execute_laser_activation():
	appear()
	switch_glow.turn_on()
	#button_sprite.frame = 0
	#laser_area2d.set_collision_mask_bit(12, 1)
	laser_area2d.set_deferred("monitorable", true)
	laser_area2d.set_deferred("monitoring", true)
	if nav_polygon:
		nav_polygon.enabled = false
	#emit_signal("beam_was_activated")
	call_deferred("emit_signal", "beam_was_activated")


func _toggle_laser_state(no_audio: bool = false, recursive: bool = false):
	if is_laser_activated:
		is_laser_activated = false
		_execute_laser_deactivation()
	else:
		is_laser_activated = true
		_execute_laser_activation()
	if not no_audio:
		audio_switch.play()
	if recursive:
		switch_other_lasers()


func appear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(beam, "width", 0.0, 50.0, growth_time)
	tween.start()
	glow1.visible = true
	glow2.visible = true


func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(beam, "width", 50.0, 0.0, growth_time)
	tween.start()
	glow1.visible = false
	glow2.visible = false


func _on_ButtonArea_area_shape_entered(_area_rid, area:Area2D, _area_shape_index, _local_shape_index):
	if switch_on_roof and area.name == "Cockroach" and area.get_parent().is_on_roof:
		_toggle_laser_state(false, true)
	elif not switch_on_roof and area.name == "Cockroach":
		_toggle_laser_state(false, true)


func _on_LaserArea_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	if _area.name == "Cockroach" and _area.get_parent().shield_activated:
		return
	audio_electro.play()
