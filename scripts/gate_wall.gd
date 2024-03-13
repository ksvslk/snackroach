tool
extends TileMap

export(bool) var editing = false

func _process(delta:float) -> void:
	if Engine.editor_hint and editing:
		var start_point = map_to_world(Vector2.ZERO)
		var end_point = map_to_world(get_used_rect().size)
		start_point.y = 0
		end_point.y = 0
		get_parent().get_node("StartPortal").position = start_point
		get_parent().get_node("EndPortal").position = end_point
