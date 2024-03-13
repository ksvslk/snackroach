tool
extends Line2D


func _process(_delta:float) -> void:
	if Engine.editor_hint:
		var start_point = points[0]
		var end_point = points[points.size() - 1]
		$StartPortal.position = start_point
		$EndPortal.position = end_point
		
