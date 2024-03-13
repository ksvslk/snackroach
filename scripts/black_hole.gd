extends Area2D
class_name BlackHole

export(bool) var is_departure_point = true
export(NodePath) var dest_path
onready var _destination = get_node_or_null(dest_path)
onready var audio = $Audio
export(float) var original_scale = 1.2


func _on_BlackHole_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print("_on_BlackHole_body_shape_entered")
	if is_departure_point:
		audio.play()
		_animate_out(body)
	else:
		_animate_in(body)


func _animate_out(body):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(body, "scale", Vector2(0.0,0.0), 0.15)
	tween.parallel().tween_property(body, "modulate:a", 0.5, 0.15)
	tween.tween_callback(self, "_change_global_position", [body])
	tween.play()


func _animate_in(body):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(body, "scale", Vector2(original_scale,original_scale), 0.15)
	tween.parallel().tween_property(body, "modulate:a",1.0, 0.15)
	tween.tween_callback(self, "_set_body_as_arrived")
	tween.play()


func _change_global_position(body):
	if is_departure_point:
		is_departure_point = false
		body.global_position = _destination.global_position


func _set_body_as_arrived():
	is_departure_point = true
