extends Control

onready var back_button = $BackButton

onready var options_list = $OptionsList
onready var options = $Options
onready var menu_active_overlay = $MenuActiveOverlay
onready var scroll_container = $ScrollContainer

onready var meister = get_parent().get_parent() as Master
var currently_visible_suboption = null

signal switch_level


func _ready():
	if OS.get_name() != "OSX":
		rect_position.y -= C.get_bottom_safe_margin()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()

func _on_Options_pressed():
	menu_active_overlay.visible = true
	options_list.visible = true
	currently_visible_suboption = options_list
	back_button.visible = true
	_hide_all_menu_buttons()


func _on_Levels_pressed():
	scroll_container.visible = true
	options_list.hide()
	currently_visible_suboption = scroll_container


func switch_level(index):
	_on_BackButton_pressed()
	meister._start_next_level(index, true)


func _hide_all_menu_buttons():
	options.visible = false


func _show_all_menu_buttons():
	options.visible = true


func _on_BackButton_pressed():
	menu_active_overlay.visible = false
	if currently_visible_suboption:
		currently_visible_suboption.visible = false
		currently_visible_suboption = null
	back_button.visible = false
	_show_all_menu_buttons()
	

func _on_ShowLeaderboard_pressed():
	GPack.show_leaderboard(C.kingd_of_evolution_leaderboard)
	_on_BackButton_pressed()


func _on_ShowAchievements_pressed():
	GPack.show_achievements()
	_on_BackButton_pressed()


func _on_BackButton_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		event.set_pressed(false)
		_on_BackButton_pressed()

func _on_SelectedHat_gui_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		_on_BackButton_pressed()
