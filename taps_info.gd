extends HBoxContainer


func _ready():
	if OS.get_name() != "OSX":
		var safe_area = OS.get_window_safe_area()
		var screen_rect = get_viewport().get_visible_rect()
		var top_margin = safe_area.position.y
		var bottom_margin = screen_rect.y - safe_area.size.y - top_margin
		rect_global_position.y = rect_global_position.y - bottom_margin
		
	
