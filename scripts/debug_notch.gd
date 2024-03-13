extends Node2D

func _draw():
	if OS.get_name() != "OSX":
		return
		var screen_rect = get_viewport_rect()
		var safe_area = OS.get_window_safe_area()
		var top_no_go_area = Rect2(0, 0, safe_area.size.x, safe_area.position.y)
		var bottom_no_go_area = Rect2(0, top_no_go_area.end.y + safe_area.size.y, safe_area.size.x, screen_rect.size.y - top_no_go_area.size.y - safe_area.size.y)
		draw_rect(top_no_go_area, Color.violet)
		draw_rect(bottom_no_go_area, Color.yellow)
