tool
extends TileMap
class_name AdjustableTileMap

export(float, 0.1, 5.0, 0.01) var pit_edge_margin = 1.2
export(bool) var run_editor_code = false


func _process(_delta: float):
	if Engine.editor_hint and run_editor_code:
		var collision_shape := get_parent().get_node("CollisionShape2D") as CollisionShape2D
		var light := get_parent().find_node("Light2D") as Light2D
		var used_rect := get_used_rect() as Rect2
		var pos = map_to_world(used_rect.get_center())
		collision_shape.position = pos
		if light:
			light.position = pos
		var factor: float = cell_size.x / 2.0
		if collision_shape.shape is RectangleShape2D:
			var x_relation_to_y: float = used_rect.size.x / used_rect.size.y
			var y_con: float = factor / pit_edge_margin
			var x_con: float = factor / pit_edge_margin + x_relation_to_y
			var X: float = used_rect.size.x * x_con
			var Y: float = used_rect.size.y * y_con
			var shape = collision_shape.shape as RectangleShape2D
			shape.extents = Vector2(X, Y)
		
		elif collision_shape.shape is CircleShape2D:
			factor = factor / pit_edge_margin
			var R: float = used_rect.size.x * factor
			var shape = collision_shape.shape as CircleShape2D
			shape.radius = R
			if light:
				var new_light_texture_size = light.texture.get_size().x * light.scale.x
				if new_light_texture_size < shape.radius * 4:
					light.scale += Vector2(0.1, 0.1)
