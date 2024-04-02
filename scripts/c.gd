# c.gd

extends Node

const next_state: String = "NextState"
const previous_state: String = "PreviousState"
const state_before_prepare: String = "StateBeforePrepare"
const snack_points_coefficient: int = 100


# States
const idle_state: String = "Idle"
const walking_state: String = "Walking"
const drunk_walking_state: String = "DrunkWalking"
const bouncing_state: String = "Bouncing"
const smashed_state: String = "Smashed"
const success_State: String = "Success"
const falling_state: String = "Falling"
const cover_state: String = "Cover"
const electrocuted_state: String = "Electrocuted"
const eating_state: String = "Eating"
const moving_state: String = "Moving"
const fighting_state: String = "Fighting"

# Animations
const idle_animation: String = "IDLE"
const moving_animation: String = "MOVING"
const walking_animation: String = "WALKING"
const bouncing_animation: String = "BOUNCING"
const smashed_animation: String = "SMASHED"
const smashed_conveyer_animation: String = "SMASHED_ON_CONVEYER"
const falling_animation: String = "FALL"
const eating_animation: String = "EATING"
const fighting_animation: String = "FIGHT"
const drunk_animation: String = "DRUNK"

# Actions
enum Actions {
	NONE,
	IN_BETWEEN
	COVER
}

# Action button states
enum ButtonState {
	ACTION,
	AD,
	IN_PROGRESS
}


# Food tile names
const snacks = {
	"bread":Color("#fae6b8"),
	"cheese":Color("#f9ac28"),
	"bacon":Color("#f7d8d5"),
	"tomato":Color("#9d1b22"),
	"cucumber":Color("#96d47f"),
	"fish":Color("#f4726f"),
	"pepperoni":Color("#ba2325"),
	"egg":Color("#ffffff"),
	"onion":Color("#e0b1c4"),
	"mushroom":Color("#e7a28a"),
	"olive":Color("#4d2440"),
	"red paprika":Color("#f1464b"),
	"green paprika":Color("#51ae57"),
	"meat":Color("#ba2d3e"),
	"sausage":Color("#ea6473"),
	"salad":Color("#388b4a")
}


# groups
const pits_group = "pits_group"
const roofs_group = "roofs_group"
const barriers_group = "barriers_group"
const tappable_group = "tappable"

# collision
const ROOF_BIT: int = 7
const THROWABLE_BIT: int = 2

# sections
# "1", "2", "3" etc. for levels
const actions_section: String = "actions"
const various_section: String = "various"

# keys


# ######################################### #
# This key is set for the VARIOUS section   #
# ######################################### #

# Initial value is 1, UPDATE on level change
const current_level_key: String = "progress"

const global_sound_volume: String = "global_sound_volume"
const global_music_volume: String = "global_music_volume"

const global_haptic_feedback: String = "global_haptic_feedback"
const global_hat: String = "global_hat"
const fullscreen: String = "fullscreen"

const unlock_all_levels_active: String = "unlock_all_levels_active"
const unlimited_taps_active: String = "unlimited_taps_active"

# 5 given at start, UPDATE when decreased or UPDATE when rewarded
#const shields_key: String = "shields"

# ################################################# #
# The following keys are set for each LEVEL section #
# ################################################# #

# This never changes and is a FIXED value for each level (it is set for each level scene)
const par_key: String = "par"

# Initial value is 0, UPDATE on level complete
const best_score_key: String = "best_score"

# Initial value is "not set", UPDATE on level complete
const best_taps_key: String = "best_taps"

# When level starts it is "par", UPDATE accordingly !
const current_snacks_key: String = "current_snacks"

# When level starts it is 0, UPDATE on "tap" and "cover"
const current_taps_key: String = "current_taps" 

# When level starts it is 0, UPDATE when dead and when level complete
const tries_key: String = "tries"

# How many times watched ads (-1 is unlimited taps, user has bought the pack)
const taps_reward_count: String = "taps_reward_count" 

# Has user completed level with par
const passed_with_par: String = "passed_with_par" 

# Has user completed level with birdie
const passed_with_birdie: String = "passed_with_birdie" 

# Has user completed level with eagle
const passed_with_eagle: String = "passed_with_eagle" 

# Has user completed level with hole-in-one
const passed_with_hole_in_one: String = "passed_with_hole_in_one" 


const unlocked: String = "unlocked"


const various_section_dictionary_keys = [
	current_level_key,
	global_sound_volume,
	global_music_volume,
	global_haptic_feedback,
	unlimited_taps_active,
	unlock_all_levels_active
]

const level_section_dictionary_keys = [
	best_score_key,
	best_taps_key,
	taps_reward_count,
	passed_with_par,
	passed_with_birdie,
	passed_with_eagle,
	passed_with_hole_in_one,
	unlocked
]

# z indexes

const floor_z_index = 0
const enemy_z_index = 1
const roach_z_index = 2
const enemy_eating_z_index = 3
const rooftop_z_index = 4
const switch_on_roof_z_index = 4
const roach_on_roof_z_index = 5
const shelter_z_index = 6
const impact_z_index = 7
const rock_z_index = 8
const tap_mark_z_index = 9


const success_vibration = 4;
const fail_vibration = 17;
const soft_vibration = 3;
const tap_vibration = 1;


const luminosity_while_on_roof: float = 0.2


func get_top_safe_margin() -> float:
	var safe_area = OS.get_window_safe_area()
	var top_no_go_area = Rect2(0, 0, safe_area.size.x, safe_area.position.y)
	#"top_no_go_area.position.y: ", top_no_go_area.position.y)
	if (top_no_go_area.size.y > 0):
		return top_no_go_area.size.y
	else:
		return 16.0


func get_bottom_safe_margin() -> float:
	var safe_area = OS.get_window_safe_area()
	var screen_rect = Rect2(Vector2(0,0), Vector2(safe_area.size.x + safe_area.position.x, safe_area.size.y + safe_area.position.y))
	var top_no_go_area = Rect2(0, 0, safe_area.size.x, safe_area.position.y)
	var bottom_no_go_area = Rect2(0, top_no_go_area.end.y + safe_area.size.y, safe_area.size.x, screen_rect.size.y - top_no_go_area.position.y - safe_area.size.y)
	#"bottom_no_go_area.size.y: ", bottom_no_go_area.size.y)
	if (top_no_go_area.size.y > 0):
		return bottom_no_go_area.size.y
	else:
		return 16.0


