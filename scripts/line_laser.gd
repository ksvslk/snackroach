tool
extends Line2D

export(bool) var is_editor_hint_on = false

func _process(delta:float) -> void:
	if Engine.editor_hint and is_editor_hint_on:
		var start_point = points[0]
		var end_point = points[points.size() - 1]
		$StartPortal.position = start_point
		$EndPortal.position = end_point
		var col = get_parent().get_node("CollisionShape2D")
		var dist = abs(start_point.x-end_point.x)/2
		col.position.x = dist
		col.shape.extents.x = dist
		
		
