# master.gd

extends Node
class_name Master

var level = null
onready var level_switcher := $GamePlayMenu/LevelSwitcher as LevelSwitcher
onready var overlay_button := $GamePlayMenu/OverlayButton as CenterContainer

onready var continue_button = $GamePlayMenu/OverlayButton/ContinueButton
onready var restart_or_skip = $GamePlayMenu/OverlayButton/RestartOrSkip
onready var skip_level_for_rewarded = $GamePlayMenu/OverlayButton/RestartOrSkip/SkipLevelForRewarded
onready var skip_level = $GamePlayMenu/OverlayButton/RestartOrSkip/SkipLevel

onready var tv = $GamePlayMenu/OverlayButton/TV
onready var result = $GamePlayMenu/OverlayButton/TV/Info/Result
onready var score = $GamePlayMenu/OverlayButton/TV/Info/Score
onready var compliment = $GamePlayMenu/OverlayButton/TV/Info/Compliment

onready var overlay_taps_exceeded = $GamePlayMenu/OverlayTapsExceeded
onready var hat_switch = $SettingsMenu/OptionsContainer/OptionsList/HatSwitch

onready var level_label = $GamePlayMenu/TapsInfoBar/LevelNr
onready var par_taps = $GamePlayMenu/TapsInfoBar/ParTaps
onready var total_taps = $GamePlayMenu/TapsInfoBar/TotalTaps
var current_total_taps = -1
var total_taps_tapped = 0

onready var score_table = $GamePlayMenu/ScoresContainer/VBoxContainer/ScoreTable
onready var player_progress = $GamePlayMenu/ScoresContainer/VBoxContainer/PlayerProgress
onready var scores_container = $GamePlayMenu/ScoresContainer

var end_scene = null
var new_score_and_diff = null

enum GameState {
	PLAYING = 0,
	FAIL = 1,
	COMPLETE = 2,
	PAUSED = 3
}

var game_state = GameState.PLAYING


func _ready():
	_disable_playing()
	if OS.get_name() == "Android" && !C.is_amazon:
		GPack.android_plugin.connect(GPack.s_on_start_loading_saved_game, self, "_show_loading_game")
		GPack.android_plugin.connect(GPack.s_on_loading_saved_game_complete, self, "_show_loading_game_result")
		GPack.android_plugin.connect(GPack.s_reward_earned, self, "_give_reward")
		GPack.android_plugin.connect(GPack.s_rewarded_ad_was_not_ready_to_show, self, "_rewarded_ad_showing_failed")
		GPack.android_plugin.connect(GPack.s_on_rewarded_ad_failed_to_show, self, "_rewarded_ad_showing_failed")
		GPack.android_plugin.connect(GPack.s_on_loading_player_scores, self, "_show_loading_bar_for_scores")
		GPack.android_plugin.connect(GPack.s_on_player_scores_loaded, self, "_show_tap_to_continue_and_scores")
		GPack.load_game()
	elif OS.get_name() == "iOS":
		GPack.load_game()
		_enable_playing()
	else:
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


func connect_and_send_ios_player_centred_scores():
	if GPack.game_center and GPack.game_center.is_authenticated():
		GPack.game_center.connect("scores_fetched", self, "_show_tap_to_continue_and_scores_ios", [], CONNECT_ONESHOT)
		GPack.game_center.connect("scores_failed", self, "_activate_tap_to_continue", [false])
		GPack.game_center.send_player_centred_scores(C.kings_of_evolution)


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
	skip_level_for_rewarded.visible = false
	

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
		skip_level_for_rewarded.visible = false
		skip_level.visible = true
	else:
		skip_level_for_rewarded.activate_button_when_conditions_met()


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
	if !C.is_amazon:
		score.text = str(info[3]) + " pts"
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
	if !info[4] or (OS.get_name() != "Android" and OS.get_name() != "iOS") or !GPack.is_signed_in():
		_activate_tap_to_continue(false)
	else:
		_activate_tap_to_continue(true)
		#connect_and_send_ios_player_centred_scores()
	_log_event()


func execute_more_level_complete_actions():
	Data.unlock_regular_achievements_in_bulk()
	Data.unlock_next_level()


func _activate_tap_to_continue(show_score_table:bool):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	continue_button.modulate.a = 0.0
	continue_button.visible = true
	if show_score_table and OS.get_name() == "Android":
		player_progress.modulate.a = 0.0
		scores_container.modulate.a = 0.0
		scores_container.visible = true
		tween.parallel().tween_property(player_progress, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(scores_container, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(continue_button, "modulate:a", 1.0, 0.5)
	tween.tween_callback(self, "_enable_continue")
	tween.play()
	
	
func _enable_continue():
	overlay_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		
func _show_loading_bar_for_scores():
	pass
	#print("Should show loading bar for loading scores here...")
	

#playersInfoDict["player"] = playerArray;
#playersInfoDict["score"] = scoreArray;
#playersInfoDict["rank"] = rankArray;
#playersInfoDict["isCurrentPlayer"] = isCurrentPlayerArray;
func _show_tap_to_continue_and_scores_ios(scoreInfo: Dictionary):
	if game_state == GameState.COMPLETE:
		var score_line_resource = load("res://scenes/ScoreLine.tscn") as Resource
		var players = scoreInfo["player"]
		var scores = scoreInfo["score"]
		var ranks = scoreInfo["rank"]
		var isCurrent = scoreInfo["isCurrentPlayer"]
	
		for i in range(players.size()):
			var score_line := score_line_resource.instance() as ScoreLine
			score_line.player_text = players[i] + "\n" + scores[i] + " pts"
			score_line.rank_text = "#" + ranks[i]
			var isCurrentPlayer = isCurrent[i] == 1
			
			# player is 1st, show appropriate text
			if i == 0 and isCurrentPlayer:
				player_progress.text = tr("you_are_the_best")
			if i > 0 and isCurrentPlayer:
				var better_player = players[i-1]
				# there is a better player, show engaging message
				if better_player != null:
					player_progress.text = tr("keep_it_up")
			# set the button style depending if it is current player or not
			if isCurrentPlayer:
				score_line.stylebox_color = Color.black
				score_line.font_color = Color.greenyellow
			else:
				score_line.stylebox_color = Color("#e6090909")
				score_line.font_color = Color.white
			score_table.add_child(score_line)
	_activate_tap_to_continue(true)
	GPack.game_center.disconnect("scores_failed", self, "_activate_tap_to_continue")


func _show_tap_to_continue_and_scores(scores: Array, next_player: String):
	#print("_show_tap_to_continue_and_scores", scores)
	
	if game_state == GameState.COMPLETE:
		
		var show_score_table = scores.size() == 3
		if show_score_table:
			var score_line = load("res://scenes/ScoreLine.tscn") as Resource
			for line in scores:
				if line != "":
					var st = (line as String)
					var arr = st.split("*")
					var rank = arr[0]
					var player_name = arr[1]
					var player_score = arr[2]
					var next_score := score_line.instance() as ScoreLine
					next_score.player_text = player_name + "\n" + player_score + " pts"
					next_score.rank_text = rank
					if (player_name == "YOU"):
						next_score.stylebox_color = Color.black
						next_score.font_color = Color.greenyellow
					else:
						next_score.stylebox_color = Color("#e6090909")
						next_score.font_color = Color.white
					score_table.add_child(next_score)
					if next_player == "BEST":
						player_progress.text = tr("you_are_the_best")
					elif next_player == "TIE":
						player_progress.text = tr("keep_it_up")
					else:
						player_progress.text = tr("keep_it_up")
				else:
					for child in score_table.get_children():
						score_table.remove_child(child)
						child.queue_free()
					show_score_table = false
		_activate_tap_to_continue(show_score_table)


func _reset_overlay_button():
	scores_container.visible = false
	overlay_button.visible = false
	
	skip_level_for_rewarded.visible = false
	
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
	for child in score_table.get_children():
		score_table.remove_child(child)
		child.queue_free()


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


func _on_SkipLevelForRewarded_gui_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if OS.get_name() == "Android":
			if GPack.is_rewarded_ad_loaded():
				GPack.show_rewarded_ad("skip_level_rewarded")
		elif OS.get_name() == "iOS":
			$SettingsMenu/OptionsContainer._on_Bonus_pressed(false, true)


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


func _on_DebugSkipContinue_pressed():
	$GamePlayMenu/ScoresContainer.visible = not $GamePlayMenu/ScoresContainer.visible		


var langs = TranslationServer.get_loaded_locales()
var temp_langs = TranslationServer.get_loaded_locales()

var temp_score_test = [tr("keep_it_up"), "ThisIsOneHellOfAPlayer" + ": " + "\n" + tr("catch_me_if_you_can"), tr("you_are_the_best")]

func _on_DebugNext_pressed():
	if temp_langs.size() > 0:
		var next_language = temp_langs[0]
		$GamePlayMenu/ScoresContainer/VBoxContainer/PlayerProgress.text = ""
		temp_score_test.clear()
		print("next language: ", next_language)
		TranslationServer.set_locale(next_language)
		$SettingsMenu/OptionsContainer/BonusList/UnlimitedTaps.text = (tr("unlimited_clicks") + "\n" + "299999$").to_upper()
		$SettingsMenu/OptionsContainer/BonusList/UnlockAllLevels. text = (tr("skip_levels") + "\n" + "199999$").to_upper()
		$GamePlayMenu/OverlayButton/TV/Info/Score.text = tr("score") + ": " + "19900"
		temp_langs.remove(0)
	else:
		print("All languages checked!")
		temp_langs.append_array(langs)


func _on_DebugContinue2_pressed():
	if temp_score_test.size() > 0:
		var next = temp_score_test[0]
		temp_score_test.remove(0)
		$GamePlayMenu/ScoresContainer/VBoxContainer/PlayerProgress.text = next
	else:
		print("Score table title checked for: ", TranslationServer.get_locale())
		temp_score_test.clear()
		temp_score_test.append(tr("keep_it_up"))
		temp_score_test.append("ThisIsOneHellOfAPlayer" + ": " + "\n" + tr("catch_me_if_you_can"))
		temp_score_test.append(tr("you_are_the_best"))


func _on_Previous_pressed():
	pass # Replace with function body.


func _on_Next_pressed():
	pass # Replace with function body.
