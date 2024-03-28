extends Node

onready var _config := ConfigFile.new()

const _path: String = "user://data.cfg"
const _total_levels_plus_one := 70 # each level has its own section: "1", "2" etc.
const _initial_cover_amount := 5
const _snack_score_multiplier := 100

const SNACK_BONUS := 100
const SNACK_PENALTY := 50

var current_par := -1
var current_level := "-1"

var regular_achievements_to_unlock = []

########################
#	 DATABASE PART	  #
########################	

func _ready():
	var err := _config.load(_path)
	if err == ERR_FILE_NOT_FOUND:
		 # This should be done ONLY ONCE when also cloud has no info!!!
		_set_initial_launch_settings()
	elif err != 0:
		printerr("Could not load local data. ", err)


func _add_hats_key():
	var default_hat_path = "res://graphics/hats/no_hat.png"
	var current_date = OS.get_date()
	var current_month = current_date.month
	var current_day = current_date.day
	var current_year = current_date.year
	
	if current_month == 1:
		default_hat_path = "res://graphics/hats/party.png"
	elif current_month == 12:
		default_hat_path = "res://graphics/hats/christmas.png"
	elif current_year == 2024 && current_month == 2:
		default_hat_path = "res://graphics/hats/dragon.png"
	else:
		default_hat_path = "res://graphics/hats/mexican.png"

	if _config.has_section_key(C.various_section, C.global_hat):
		return
	_config.set_value(C.various_section, C.global_hat, default_hat_path)
	_config.save(_path)

######################################
#	REPOSITORY/VIEWMODEL PART	    #
######################################

signal level_loaded(level, rewards)
signal tap()
signal global_sound_changed(value)
signal global_haptic_changed(value)
signal unlock_all_levels
signal unlimited_taps
signal all_in_pack
signal level_unlocked(index)
signal roach_hat_change


func add_regular_achievement(id:String):
	regular_achievements_to_unlock.append(id)


func unlock_regular_achievements_in_bulk():
	for ach in regular_achievements_to_unlock:
		GPack.unlock_achievement(ach)
	regular_achievements_to_unlock.clear()


func increase_taps():
	emit_signal("tap")


func increase_taps_reward_count():
	var rewards = _config.get_value(current_level, C.taps_reward_count)
	_config.set_value(current_level, C.taps_reward_count, rewards + 1)
	_config.save(_path)
	
	
func load_current_level():
	current_level = String(_config.get_value(C.various_section, C.current_level_key))
	var rewards = _config.get_value(current_level, C.taps_reward_count)
	emit_signal("level_loaded", int(current_level), rewards)
	
	
func restart_level():
	var rewards = _config.get_value(current_level, C.taps_reward_count)
	emit_signal("level_loaded", int(current_level), rewards)


func load_next_level(nr: int = -1, from_level_select: bool = false):
	if nr == -1:
		current_level = str(int(current_level) + 1)
	else:
		current_level = str(nr)
	_config.set_value(C.various_section, C.current_level_key, current_level)
	_config.save(_path)
	var rewards = _config.get_value(current_level, C.taps_reward_count)
	emit_signal("level_loaded", int(current_level), rewards)


func get_level_complete_info() -> Dictionary:
	return {
		"par":current_par,
		"current_best_score":_config.get_value(current_level, C.best_score_key),
		"rewards":_config.get_value(current_level, C.taps_reward_count)
	}


func unlock_next_level():
	var current = int(current_level)
	if current != 69:
		var level_to_be_unlocked = current + 1
		_config.set_value(str(level_to_be_unlocked), C.unlocked, 1)
		_config.save(_path)
		emit_signal("level_unlocked", level_to_be_unlocked - 1)


func _get_total_score() -> int:
	var total = 0
	for i in range(1, _total_levels_plus_one):
		total += _config.get_value(String(i), C.best_score_key)
	return total
	

func _calculate_new_score(diff: int, snacks: int) -> int:
	var new_score := 0
	# UNDER PAR
	if diff < 0:
		new_score = (snacks + abs(diff)) * SNACK_BONUS
	#OVER PAR
	else:
		new_score = snacks * SNACK_BONUS
		new_score -= diff * SNACK_PENALTY
	if new_score < 0:
		new_score = 0
	return new_score


func _save_current_level_new_score(_taps:int, new_score: int) -> void:
	var best_score = _config.get_value(current_level, C.best_score_key)
	if new_score > best_score:
		_config.set_value(current_level, C.best_score_key, new_score)
	_config.save(_path)

const levels_to_show_scores = [6, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66]
func _is_showing_user_centered_scores() -> bool:
	if levels_to_show_scores.has(int(current_level)):
		return true
	return false

# info array
# 0. compliment (string)
# 1. codeword (string
# 2. play animation (int)
# 3. score (int)
# 4. current level (int)
func get_finish_line_info(taps: int, par: int, snacks: int) -> Array:

	var diff = taps - par
	var compliment = ""
	var codeword = ""
	var play_animation = 0
	var show_scores = _is_showing_user_centered_scores()
	
	var current_level_new_score = _calculate_new_score(diff, snacks)
	_increment_achievements(taps, diff)
	_save_current_level_new_score(taps, current_level_new_score)
	var total_score = _get_total_score()
	GPack.submit_score(total_score, C.kingd_of_evolution_leaderboard, show_scores)

	if taps == 1:
		compliment = tr("woohoo")+"\u00A0"
		codeword = "Hole-In-One"
		play_animation =0
		return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		
	match diff:
		-4:
			compliment = tr("wow_just_wow")+"\u00A0"
			codeword = "Condor: -4"
			play_animation = 0
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		-3:
			compliment = tr("amazing")+"\u00A0"
			codeword = "Albatross: -3"
			play_animation = 0
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		-2:
			compliment = tr("unbelievable")+"\u00A0"
			codeword = "Eagle: -2"
			play_animation = 0
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		-1:
			compliment = tr("professional")+"\u00A0"
			codeword = "Birdie: -1"
			play_animation = 0
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		0:
			compliment = tr("very_good")+"\u00A0"
			codeword = "Par: 0"
			play_animation = 1
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		1:
			compliment = tr("good_job")+"\u00A0"
			codeword = "Bogey: +1"
			play_animation = 2
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		2:
			compliment = tr("you_made_it")+"\u00A0"
			codeword = "Bogey: +2"
			play_animation = 2
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
		3:
			compliment = tr("you_did_it")+"\u00A0"
			codeword = "Bogey: +3"
			play_animation = 2
			return [compliment, codeword, play_animation, current_level_new_score, show_scores]
			
	if diff < -4:
		compliment = tr("superb")+"\u00A0"
		codeword = str(abs(diff)) + "-under par"
		play_animation = 0
	elif diff > 3:
		compliment = tr("well_you_finished")+"\u00A0"
		codeword = str(diff) + "-over par"
		play_animation = 2
		
	return [compliment, codeword, play_animation, current_level_new_score, show_scores]
	
	
func _increment_achievements(taps, diff):
	var passed_with_par = _config.get_value(current_level, C.passed_with_par)
	var passed_with_birdie = _config.get_value(current_level, C.passed_with_birdie)
	var passed_with_eagle = _config.get_value(current_level, C.passed_with_eagle)
	var passed_with_hole_in_one = _config.get_value(current_level, C.passed_with_hole_in_one)
	if taps == 1:
		if not passed_with_hole_in_one:
			GPack.increment_achievement(C.achievement_5xholeinone, 1)
			_config.set_value(current_level, C.passed_with_hole_in_one, 1)
	match diff:
		-4:
			#codeword ="Condor: -4"
			pass
		-3:
			#codeword ="Albatross: -3"
			pass
		-2:
			#codeword ="Eagle: -2"
			if not passed_with_eagle:
				GPack.increment_achievement(C.achievement_10xeagle, 1)
				_config.set_value(current_level, C.passed_with_eagle, 1)
		-1:
			#codeword ="Birdie: -1"
			if not passed_with_birdie:
				GPack.increment_achievement(C.achievement_20xbirdie, 1)
				_config.set_value(current_level, C.passed_with_birdie, 1)
		0:
			#codeword ="Par: 0"
			if not passed_with_par:
				GPack.increment_achievement(C.achievement_30xpar, 1)
				_config.set_value(current_level, C.passed_with_par, 1)
		1:
			pass
			#codeword = "Bogey: +1"
	_config.save(_path)


func increase_achievement_progress(id:String, increment:float) -> float:
	var current_progress = _config.get_value(C.various_section, id)
	var new_progress = float(current_progress) + increment
	_config.set_value(C.various_section, id, new_progress)
	_config.save(_path)
	return new_progress


func get_levels() -> Dictionary:
	var info = Dictionary()
	for i in range(1, _total_levels_plus_one):
		info[str(i)] = [
			_config.get_value(str(i), C.unlocked)
		]
	return info

# Sound and haptic feedback button/game state
func set_sound_volume(value:float) -> void:
	_config.set_value(C.various_section, C.global_sound_volume, value)
	_config.save(_path)


func get_sound_volume() -> float:
	var value = _config.get_value(C.various_section, C.global_sound_volume)
	return value


func set_music_volume(value:float) -> void:
	_config.set_value(C.various_section, C.global_music_volume, value)
	_config.save(_path)


func get_music_volume() -> float:
	var value = _config.get_value(C.various_section, C.global_music_volume)
	return value


func set_fullscreen(value:int) -> void:
	_config.set_value(C.various_section, C.fullscreen, value)
	_config.save(_path)


func get_fullscreen() -> int:
	var value = _config.get_value(C.various_section, C.fullscreen)
	return value

func _set_haptic_feedback():
	GPack.haptic_enabled = get_haptic_feedback_state()

func get_haptic_feedback_state() -> bool:
	return _config.get_value(C.various_section, C.global_haptic_feedback)

func set_hat_path(value:String) -> void:
	_config.set_value(C.various_section, C.global_hat, value)
	_config.save(_path)
	emit_signal("roach_hat_change", value)


func get_hat_path() -> String:
	return _config.get_value(C.various_section, C.global_hat)


#Purchase and goods button/game state

#get
func get_unlimited_taps_state() -> int:
	return _config.get_value(C.various_section, C.unlimited_taps_active)


func get_unlock_all_levels_state() -> int:
	return _config.get_value(C.various_section, C.unlock_all_levels_active)

#set
func set_unlimited_taps_state(value:int) -> void:
	_config.set_value(C.various_section, C.unlimited_taps_active, value)
	_config.save(_path)
	

func set_unlock_all_levels_state(value:int) -> void:
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.unlocked, 1)
	_config.set_value(C.various_section, C.unlock_all_levels_active, value)
	_config.save(_path)
	

func set_all_in_pack_state(value:int) -> void:
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.unlocked, 1)
	_config.set_value(C.various_section, C.unlimited_taps_active, value)
	_config.set_value(C.various_section, C.unlock_all_levels_active, value)
	_config.save(_path)


func _set_initial_launch_settings():
	_config.set_value(C.various_section, C.current_level_key, "1")
	_config.set_value(C.various_section, C.fullscreen, 1)
	_config.set_value(C.various_section, C.global_music_volume, 1.0)
	_config.set_value(C.various_section, C.global_sound_volume, 1.0)
	_config.set_value(C.various_section, C.global_haptic_feedback, 1)
	_config.set_value(C.various_section, C.unlimited_taps_active, 0)
	_config.set_value(C.various_section, C.unlock_all_levels_active, 0)
	
	_config.set_value(C.various_section, C.five_times_hole_in_one, 0.0)
	_config.set_value(C.various_section, C.collect_10_eagles, 0.0)
	_config.set_value(C.various_section, C.collect_20_birdies, 0.0)
	_config.set_value(C.various_section, C.collect_30_pars, 0.0)
	
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.best_score_key, 0)
		_config.set_value(String(i), C.best_taps_key, -1)
		_config.set_value(String(i), C.taps_reward_count, 0)
		_config.set_value(String(i), C.passed_with_par, 0)
		_config.set_value(String(i), C.passed_with_birdie, 0)
		_config.set_value(String(i), C.passed_with_eagle, 0)
		_config.set_value(String(i), C.passed_with_hole_in_one, 0)
		if i == 1:
			_config.set_value(String(i), C.unlocked, 1)
		else:
			_config.set_value(String(i), C.unlocked, 1)
	_add_hats_key()
	_config.save(_path)
