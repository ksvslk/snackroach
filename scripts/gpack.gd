extends Node

var ios_plugin = null
var game_center = null
var icloud = null

var android_plugin = null
var plugin = null

var current_ad = ""
var haptic_enabled = true


func _ready():
	if Engine.has_singleton("GPack"):
		android_plugin = Engine.get_singleton("GPack")
	if Engine.has_singleton("IPack"):
		ios_plugin = Engine.get_singleton("IPack")
	if Engine.has_singleton("GameCenter"):
		game_center = Engine.get_singleton("GameCenter")
		game_center.authenticate()
	if Engine.has_singleton("ICloud"):
		icloud = Engine.get_singleton("ICloud")
	else:
		print("iOS Game Center plugin is not available on this platform.")


func is_signed_in() -> bool:
	if android_plugin && !C.is_amazon:
		return android_plugin.isSignedIn()
	elif game_center:
		return game_center.is_authenticated()
	return false
	

func ask_for_review():
	if GPack.android_plugin && !C.is_amazon:
		android_plugin.askForReview()
	elif Engine.has_singleton("InAppStore"):
		var ias = Engine.get_singleton("InAppStore")
		ias.ask_for_review()
	

################
# ACHIEVEMENTS #
################

func unlock_achievement(id: String) -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.unlockAchievement(id)
	elif game_center:
		var ios_achievement = map_android_achievement_to_ios(id)
		game_center.award_achievement({ 
				"name":ios_achievement,
				"progress":100.0,
				"show_completion_banner":true
		})


func map_android_achievement_to_ios(android_achievement:String) -> String:
	if android_achievement == C.achievementDarkRoach:
		return C.dark_roach
	elif android_achievement == C.achievementSecretRoom2:
		return C.secret_room_2
	elif android_achievement == C.achievementSecretRoom1:
		return C.secret_room_1
	elif android_achievement == C.achievement_neutralize_with_rock:
		return C.neutralize_with_rock
	elif android_achievement == C.achievement_start_a_fight:
		return C.start_a_fight
	elif android_achievement == C.achievement_meet_beetle:
		return C.meet_beetle
	elif android_achievement == C.achievement_30xpar:
		return C.collect_30_pars
	elif android_achievement == C.achievement_neutralized_with_laser:
		return C.neutralized_with_laser
	elif android_achievement == C.achievement_5xholeinone:
		return C.five_times_hole_in_one
	elif android_achievement == C.achievement_10xeagle:
		return C.collect_10_eagles
	elif android_achievement == C.achievement_20xbirdie:
		return C.collect_20_birdies
	elif android_achievement == C.achievement_crown:
		return C.crown
	return ""


func increment_achievement(id: String, num_steps: int) -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.incrementAchievement(id, num_steps)
	elif game_center:
		var ios_achievement = map_android_achievement_to_ios(id)
		var increment = get_increment_for_achievement(ios_achievement)
		var new_progress = Data.increase_achievement_progress(ios_achievement, increment)
		#"New progress for ", ios_achievement, " is ", new_progress)
		game_center.award_achievement({ 
			"name":ios_achievement,
			"progress":new_progress,
			"show_completion_banner":true
		})


func get_increment_for_achievement(id:String) -> float:
	match id:
		C.collect_10_eagles:
			return 10.0
		C.collect_20_birdies:
			return 5.0
		C.collect_30_pars:
			return 3.34
		C.five_times_hole_in_one:
			return 20.0
	return -1.0


func show_achievements() -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.showAchievements()
	elif game_center:
		game_center.show_game_center({ "view":"achievements" })


################
# LEADERBOARD  #
################


func submit_score(score: int, leaderboard: String, send_scores:bool = false) -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.submitScore(score, leaderboard,send_scores)
	elif game_center:
		game_center.post_score({ "score": score, "category": C.kings_of_evolution, })
	

func show_leaderboard(id: String) -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.showLeaderboard(id)
	elif game_center:
		game_center.show_game_center({ "view":"leaderboards" })

################
#   FIREBASE   #
################

func log_event(event_name: String, dictionary: Dictionary) -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.logEvent(event_name, dictionary)


################
#    ADMOB     #
################

func load_rewarded_ad() -> void:
	if android_plugin && !C.is_amazon:
		android_plugin.loadRewardedAd()


func is_rewarded_ad_loaded() -> bool:
	if android_plugin && !C.is_amazon:
		return android_plugin.isRewardedAdLoaded()
	return false


func show_rewarded_ad(ad_category: String) -> void:
	if android_plugin && !C.is_amazon:
		current_ad = ad_category
		android_plugin.showRewardedAd()


# void start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0)
# Joypads usually come with two rumble motors, a strong and a weak one.
# weak_magnitude is the strength of the weak motor (between 0 and 1)
# and strong_magnitude is the strength of the strong motor (between 0 and 1).
# duration is the duration of the effect in seconds (a duration of 0 will try to play the vibration indefinitely).
# Note: Not every hardware is compatible with long effect durations; it is
# recommended to restart an effect if it has to be played for more than a few seconds.

func perform_haptic_feedback(constant:int) -> void:
	if haptic_enabled:
		if constant == C.tap_vibration:
			Input.start_joy_vibration(0, 0.1, 0.0, 0.1)
		elif constant == C.soft_vibration:
			Input.start_joy_vibration(0, 0.1, 0.0, 0.1)
		elif constant == C.fail_vibration:
			Input.start_joy_vibration(0, 0.4, 0.0, 0.4)
		elif constant == C.success_vibration:
			Input.start_joy_vibration(0, 0.2, 0.0, 0.2)


# Signals you can connect to in the Android plugin.
# Prefixed by "s" so they would be recognized more easily from various scripts.
const s_rewarded_ad_loaded = "rewarded_ad_loaded"
const s_rewarded_ad_failed_to_load = "rewarded_ad_failed_to_load"
const s_reward_earned = "reward_earned"
const s_rewarded_ad_was_not_ready_to_show = "rewarded_ad_was_not_ready_to_show"
const s_on_rewarded_ad_showed = "on_rewarded_ad_showed"
const s_on_rewarded_ad_failed_to_show = "on_rewarded_ad_failed_to_show"
const s_on_rewarded_ad_dismissed = "on_rewarded_ad_dismissed"

const s_on_start_loading_saved_game = "on_start_loading_saved_game"
const s_on_loading_saved_game_complete = "on_loading_saved_game_complete"
const s_on_start_saving_game = "on_start_saving_game"
const s_on_saving_game_complete = "on_saving_game_complete"

const s_on_signed_in_status_changed = "on_signed_in_status_changed"

const s_on_start_showing_review = "on_start_showing_review"
const s_on_ending_review = "on_ending_review"

const s_on_loading_player_scores = "on_loading_player_scores"
const s_on_player_scores_loaded = "on_player_scores_loaded"
