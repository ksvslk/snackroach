extends GridContainer

var level_button = load("res://scenes/LevelSelectButton.tscn")

func _ready():
	var levels = Data.get_levels()

	for index in range(0, levels.size()):
		var button = level_button.instance()
		var state = levels.values()[index][0] as bool
		button.level_is_unlocked = state
		button.button_text = str(index + 1)
		button.disabled = !state
		add_child(button)
		button.connect("pressed", get_parent().get_parent(), "switch_level", [index + 1])

	yield(get_tree(), "node_added")
	var safe_area_position_y = OS.get_window_safe_area().position.y
	if safe_area_position_y != 0:
		rect_global_position.y = C.get_top_safe_margin() + 75
		rect_size.y = safe_area_position_y - 228 # harcoded back button y size :(


func _set_level_buttons_state():
	var levels = Data.get_levels()
	var added_buttons = get_children()
	for index in range(0, added_buttons.size()):
		var level_button_l = get_child(index)
		var state = levels.values()[index][0] as bool
		level_button_l.level_is_unlocked = state
		level_button_l.disabled = !state


func _set(property, value):
	if property == "visible":
		if value == true:
			_set_level_buttons_state()
			visible = true
		elif value == false:
			visible = false
