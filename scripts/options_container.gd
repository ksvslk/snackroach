extends Control

onready var options_list = $OptionsList
onready var menu_active_overlay = $MenuActiveOverlay
onready var previous = $OptionsList/HatSwitch/Previous
onready var options = $"../../GamePlayMenu/InfoBarMargin/InfoBar/Options"
onready var level_scroller_container = $LevelScrollerContainer
onready var level_scroller = $LevelScrollerContainer/LevelScroller

onready var meister = get_parent().get_parent() as Master
var currently_visible_suboption = null

signal switch_level


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if currently_visible_suboption == level_scroller_container:
				level_scroller_container.visible = false
				level_scroller.visible = false
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
	level_scroller_container.visible = true
	level_scroller.visible = true
	options_list.hide()
	currently_visible_suboption = level_scroller_container


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
	

func _on_Quit_pressed():
	get_tree().quit()


func _open_options():
	if not get_tree().paused:
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


func _on_BackToMenu_gui_input(event):
	if event.is_action_pressed("ui_accept"):
		level_scroller_container.visible = false
		level_scroller.visible = false
		menu_active_overlay.visible = true
		options_list.visible = true
		currently_visible_suboption = options_list
		_hide_all_menu_buttons()
		previous.grab_focus()
