# master.gd

extends Node
class_name Master

var level = null
onready var level_switcher := $GamePlayMenu/LevelSwitcher as LevelSwitcher
onready var overlay_button := $GamePlayMenu/OverlayButton as CenterContainer

onready var continue_button = $GamePlayMenu/OverlayButton/ContinueButton
onready var restart_or_skip = $GamePlayMenu/OverlayButton/RestartOrSkip
onready var skip_level = $GamePlayMenu/OverlayButton/RestartOrSkip/SkipLevel

onready var tv = $GamePlayMenu/OverlayButton/TV
onready var result = $GamePlayMenu/OverlayButton/TV/Info/Result
onready var compliment = $GamePlayMenu/OverlayButton/TV/Info/Compliment

onready var overlay_taps_exceeded = $GamePlayMenu/OverlayTapsExceeded
onready var hat_switch = $SettingsMenu/OptionsContainer/OptionsList/HatSwitch


onready var level_label = $GamePlayMenu/InfoBarMargin/InfoBar/LevelNr

onready var par_taps = $GamePlayMenu/TapsBarMargin/TapsInfoBar/ParTaps
onready var total_taps = $GamePlayMenu/TapsBarMargin/TapsInfoBar/TotalTaps

var current_total_taps = -1
var total_taps_tapped = 0


var end_scene = null

enum GameState {
	PLAYING = 0,
	FAIL = 1,
	COMPLETE = 2,
	PAUSED = 3
}

var game_state = GameState.PLAYING


func _ready():
	Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	_enable_playing()
	if not Data.get_unlimited_taps_state():
		Data.connect("unlimited_taps", self, "change_ui_for_unlimited_tap")
	if not Data.get_unlock_all_levels_state():
		Data.connect("unlock_all_levels", self, "change_ui_for_all_levels_unlocked")
	if not Data.get_unlock_all_levels_state() and not Data.get_unlimited_taps_state():
		Data.connect("all_in_pack", self, "change_ui_for_all_in_pack")
	_print_license()
	Data.connect("roach_hat_change", self, "change_cockroach_hat")


func change_cockroach_hat(path:String):
	if level != null:
		var current_level = (level as Level)
		current_level.roach.change_hat(path)


func show_review():
	GPack.ask_for_review()


func _disable_playing():
	pass


func _enable_playing():
	_start_level()


func _start_level():
	Data.connect("level_loaded", self, "_load_level")
	Data.load_current_level()
	Data.connect("tap", self, "_increase_taps")


# THIS IS IS THE WAY ALL LEVELS SHOULD BE LOADED NOT JUST WHEN STARTING THE GAME!!!
func _load_level(level_nr: int, rewards_count:int):
	if level_nr == 25:
		show_review()
	_add_level_to_scene(level_nr)
	var current_level = (level as Level)
	total_taps_tapped = 0
	current_level.init_snacks()
	level_label.text = str(level_nr)
	par_taps.text = tr("par") + ": " + str(current_level.par)
	if Data.get_unlimited_taps_state():
		current_total_taps = "INF"
	else:
		current_total_taps = current_level.max_taps + rewards_count * current_level.rewarded_taps_amount
	total_taps.text = "0 / " + str(current_total_taps)
	Data.current_par = current_level.par
	_set_over_par_colors(current_level.par, 0)
	_unlock_achievements(level_nr)
	_reset_overlay_button()


func change_ui_for_unlimited_tap():
	current_total_taps = "INF"
	total_taps.text = str(total_taps_tapped) + " / " + str(current_total_taps)


func change_ui_for_all_levels_unlocked():
	skip_level.visible = true
	

func change_ui_for_all_in_pack():
	change_ui_for_unlimited_tap()
	change_ui_for_all_levels_unlocked()


func _unlock_achievements(level_nr: int):
	if level_nr == 14:
		Data.add_regular_achievement(C.achievementDarkRoach)
	elif level_nr == 26:
		Data.add_regular_achievement(C.achievement_meet_beetle)


func _increase_taps() -> void:
	var current_level = level as Level
	if not Data.get_unlimited_taps_state():
		if total_taps_tapped == current_total_taps - 1:
			current_level.tapping_enabled = false
			_show_screen_of_taps_exceeded()
	total_taps_tapped += 1
	total_taps.text = str(total_taps_tapped) + " / " + str(current_total_taps)
	if total_taps_tapped > current_level.par:
		current_level.snacks.decrease_snacks()
	_set_over_par_colors(current_level.par, total_taps_tapped)


func _show_screen_of_taps_exceeded():
	overlay_taps_exceeded.show()
	game_state = GameState.FAIL
	overlay_button.mouse_filter = Control.MOUSE_FILTER_STOP
	Data.unlock_regular_achievements_in_bulk()


func _set_over_par_colors(par:int, new_taps:int):
	if new_taps < par:
		total_taps.modulate = Color.greenyellow
	elif new_taps == par:
		total_taps.modulate = Color.aqua
	else:
		total_taps.modulate = Color.deeppink


func _connect_signals():
	level.connect("game_over", self, "_on_Level_game_over")
	level.connect("finished", self, "_on_Level_finished")


func _on_Level_game_over():
	print("game over _on_Level_game_over: ", game_state)
	Data.unlock_regular_achievements_in_bulk()
	if not overlay_taps_exceeded.visible and not overlay_button.visible:
		game_state = GameState.FAIL
		overlay_button.mouse_filter = Control.MOUSE_FILTER_STOP
		var tween := get_tree().create_tween().set_ease(Tween.EASE_IN)
		overlay_button.modulate.a = 0.0
		overlay_button.visible = true
		tween.tween_property(overlay_button, "modulate:a", 1.0, 0.5)
		tween.play()
		_change_ui_for_all_levels_unlocked()
	else:
		game_state = GameState.FAIL
	if level:
		GPack.log_event("FAIL_LEVEL_" + Data.current_level, {
			"TAPS":current_total_taps,
			"MAX_TAPS":level.max_taps,
			"PAR":Data.current_par,
		})


func _change_ui_for_all_levels_unlocked():
	restart_or_skip.visible = true
	if Data.get_unlock_all_levels_state():
		skip_level.visible = true


func _animate_overlay_button():
	if overlay_taps_exceeded.visible:
		overlay_taps_exceeded.visible = false
	overlay_button.visible = true
	overlay_button.modulate.a = 0.0
	overlay_button.visible = true
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(overlay_button, "modulate:a", 1.0, 0.5)
	tween.tween_callback(self, "execute_more_level_complete_actions")
	tween.play()


func _show_result_on_tv(info: Array):
	result.text = info[1]
	compliment.text = info[0]
	result.play_animation(info[2])
	tv.visible = true


func _log_event():
	if level:
		GPack.log_event("COMPLETE_LEVEL_" + Data.current_level, {
			"TAPS":current_total_taps,
			"MAX_TAPS":level.max_taps,
			"PAR":Data.current_par
		})


func _on_Level_finished():
	print("game_state _on_Level_finished: ", game_state)
	game_state = GameState.COMPLETE
	_animate_overlay_button()
	var info = Data.get_finish_line_info(total_taps_tapped, level.par, level.snacks.snacks_count)
	_show_result_on_tv(info)
	_activate_tap_to_continue(true)
	_log_event()


func execute_more_level_complete_actions():
	Data.unlock_regular_achievements_in_bulk()
	Data.unlock_next_level()


func _activate_tap_to_continue(show_score_table:bool):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	continue_button.modulate.a = 0.0
	continue_button.visible = true
	tween.parallel().tween_property(continue_button, "modulate:a", 1.0, 0.5)
	tween.tween_callback(self, "_enable_continue")
	tween.play()
	
	
func _enable_continue():
	overlay_button.mouse_filter = Control.MOUSE_FILTER_STOP
		

func _reset_overlay_button():
	overlay_button.visible = false
	skip_level.visible = false
	continue_button.visible = false
	restart_or_skip.visible = false
	overlay_taps_exceeded.visible = false
	tv.visible = false
	overlay_button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event):
	if event.is_action_pressed("ui_accept") :
		if game_state == GameState.COMPLETE:
			_start_next_level()
			get_tree().set_input_as_handled()
		elif game_state == GameState.FAIL:
			_reset_overlay_button()
			_restart_level()
			get_tree().set_input_as_handled()


func _add_level_to_scene(level_nr: int):
	var level_file_name = "res://levels/" + str(level_nr) + ".tscn"
	var level_resource := load(level_file_name) as Resource
	level = level_resource.instance() as Level
	add_child_below_node($Place, level)
	_finish_loading_level()


func _finish_loading_level():
	_connect_signals()
	game_state = GameState.PLAYING
	level_switcher.play_start_transition()


func _start_next_level(nr: int = -1, departed_from_level_select: bool = false):
	_reset_overlay_button()
	if int(Data.current_level) == 69 and nr == -1:
		level_switcher.play_end_transition()
		yield(level_switcher, "end_transition_complete")
		remove_child(level)
		var end_screen = "res://scenes/Ending.tscn"
		var end_resource := load(end_screen) as Resource
		end_scene = end_resource.instance()
		add_child_below_node($Place, end_scene)
		level_switcher.play_start_transition()
		Data.current_level = "end"
		level = null
	else:
		level_switcher.play_end_transition()
		yield(level_switcher, "end_transition_complete")
		if level:
			remove_child(level)
			level.queue_free()
		if end_scene:
			remove_child(end_scene)
			end_scene = null
		Data.load_next_level(nr, departed_from_level_select)


func _restart_level():
	remove_child(level)
	#level.queue_free()
	level.call_deferred("queue_free")
	Data.restart_level()


func _show_loading_game():
	pass


func _show_loading_game_result(game_data: Dictionary, loading_result: bool):
	if loading_result:
		Data.load_game(game_data)
	else:
		printerr("Something went wrong when loading game... or initial start :(")
	_enable_playing()


func _give_reward(_some, _stuff):
	match GPack.current_ad:
		"add_taps_rewarded":
			GPack.log_event("ADD_TAPS_REWARD", {
				"LEVEL":int(Data.current_level),
				"PAR":Data.current_par,
				"TAPS":current_total_taps
			})
			_add_rewarded_taps()
		"skip_level_rewarded":
			GPack.log_event("SKIP_LEVEL_REWARD", {
				"LEVEL":int(Data.current_level),
				"PAR":Data.current_par,
				"TAPS":current_total_taps
			})
			Data.unlock_next_level()
			_start_next_level()


func _add_rewarded_taps():
	Data.increase_taps_reward_count()
	var current_level = (level as Level)
	current_total_taps += current_level.rewarded_taps_amount
	total_taps.text = str(total_taps_tapped) + " / " + str(current_total_taps)


func _rewarded_ad_showing_failed():
	_reset_overlay_button()
	_restart_level()


func _on_SkipLevel_gui_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		_start_next_level()


func _print_license():
	print("Copyright (c) 2007-2022 Juan Linietsky, Ariel Manzur."\
+"Copyright (c) 2014-2022 Godot Engine contributors (cf. AUTHORS.md)."\

+"Permission is hereby granted, free of charge, to any person obtaining a copy"\
+"of this software and associated documentation files (the 'Software'), to deal"\
+"in the Software without restriction, including without limitation the rights"\
+"to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"\
+"copies of the Software, and to permit persons to whom the Software is"\
+"furnished to do so, subject to the following conditions:"\

+"The above copyright notice and this permission notice shall be included in all"\
+"copies or substantial portions of the Software."\

+"THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"\
+"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"\
+"FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"\
+"AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"\
+"LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"\
+"OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"\
+"SOFTWARE.")

#######################
### DEBUG LANGUAGES ###
#######################
func _on_DebugBuyTaps_pressed():
	var value = overlay_taps_exceeded.visible
	overlay_taps_exceeded.visible = !value
	for c in overlay_taps_exceeded.get_children():
		c.visible = !value
		for cc in c.get_children():
			cc.visible = !value


func _on_DebugBuySkip_pressed():
	var value = overlay_button.visible
	overlay_button.visible = !value
	for c in overlay_button.get_children():
		c.visible = !value
		for cc in c.get_children():
			cc.visible = !value


var comps = ["woohoo", "wow_just_wow", "amazing", "unbelievable", "professional", "very_good", "good_job", "you_made_it", "you_did_it", "superb", "well_you_finished"]
var temp_comps = ["woohoo", "wow_just_wow", "amazing", "unbelievable", "professional", "very_good", "good_job", "you_made_it", "you_did_it", "superb", "well_you_finished"]

func _on_DebugContinue_pressed():
	# next compliment
	if temp_comps.size() > 0:
		$GamePlayMenu/OverlayButton/TV/Info/Compliment.text = temp_comps.pop_at(0)
	else:
		print("Compliments checked for: ", TranslationServer.get_locale())
		temp_comps.append_array(comps)


var langs = TranslationServer.get_loaded_locales()
var temp_langs = TranslationServer.get_loaded_locales()
