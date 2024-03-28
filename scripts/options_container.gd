extends Control

onready var options_list = $OptionsList
onready var menu_active_overlay = $MenuActiveOverlay
onready var scroll_container = $LevelScroller
onready var previous = $OptionsList/HatSwitch/Previous
onready var options = $"../../GamePlayMenu/InfoBarMargin/InfoBar/Options"

onready var meister = get_parent().get_parent() as Master
var currently_visible_suboption = null

signal switch_level


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if currently_visible_suboption == scroll_container:
				scroll_container.visible = false
				menu_active_overlay.visible = true
				options_list.visible = true
				currently_visible_suboption = options_list
				_hide_all_menu_buttons()
				previous.grab_focus()
		else:
			get_tree().set_input_as_handled()
			_back_to_game()
	elif event.is_action_pressed("open_options"):
		if options_list.visible == false:
			_open_options()


func _on_Levels_pressed():
	scroll_container.visible = true
	options_list.hide()
	currently_visible_suboption = scroll_container


func switch_level(index):
	_back_to_game()
	meister._start_next_level(index, true)


func _hide_all_menu_buttons():
	options.visible = false


func _show_all_menu_buttons():
	options.visible = true


func _back_to_game():
	menu_active_overlay.visible = false
	if currently_visible_suboption:
		currently_visible_suboption.visible = false
		currently_visible_suboption = null
	get_tree().paused = false
	_show_all_menu_buttons()
	

func _on_ShowLeaderboard_pressed():
	GPack.show_leaderboard(C.kingd_of_evolution_leaderboard)
	_back_to_game()


func _on_ShowAchievements_pressed():
	GPack.show_achievements()
	_back_to_game()


func _on_Quit_pressed():
	get_tree().quit()


func _open_options():
	get_tree().paused = true
	menu_active_overlay.visible = true
	options_list.visible = true
	currently_visible_suboption = options_list
	_hide_all_menu_buttons()
	$OptionsList/Back.grab_focus()


func _on_Options_gui_input(event):
	if event.is_action_pressed("ui_accept"):
		_open_options()


func _on_MenuActiveOverlay_gui_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		_back_to_game()


func _on_Back_gui_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		_back_to_game()
