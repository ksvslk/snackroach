extends Node

var is_free_weekend: bool = false
var is_owned: bool = false
var is_online: bool = false
var is_on_steam_deck: bool = false
var steam_app_id: int = 2908270
var steam_id: int = 0
var steam_username: String = ""

#ACHIEVEMENTS

# 100% by level completion
const achievements_dict = {
	14:"ACH_COMPLETE_DARK_ROACH",
	26:"ACH_COMPLETE_BEETLE",
}

# 100% by event
var rock_achievement = "ACH_COMPLETE_ROCK"
var laser_achievement = "ACH_COMPLETE_LASER"
var fight_achievement = "ACH_COMPLETE_FIGHT"
var secret1_achievement = "ACH_COMPLETE_SECRET_1"
var secret2_achievement = "ACH_COMPLETE_SECRET_2"
var crown_achievement = "ACH_COMPLETE_CROWN"

# incremental
var hole_in_one_stat_ach = "stat_5_hole_in_ones"
var eagles_stat_ach = "stat_10_eagles"
var birdies_stat_ach = "stat_20_birdies"
var pars_stat_ach = "stat_30_pars"

#ACHIEVEMENTS END


# STATS
var snacks_eaten_api_name = "snacks_eaten"
var moves_made_api_name = "moves_made"


var handle = null
var is_steam_ok = false

const language_to_locale_code:Dictionary = {
	"arabic":"ar",
	"german":"de",
	"english":"en",
	"spanish":"es",
	"latam":"es",
	"finnish":"fi",
	"french":"fr",
	"indonesian":"id",
	"italian":"it",
	"japanese":"ja",
	"koreana":"ko",
	"norwegian":"nb",
	"portuguese":"pt",
	"brazilian":"pt",
	"russian":"ru",
	"swedish":"sv",
	"thai":"th",
	"turkish":"tr",
	"ukrainian":"uk",
	"vietnamese":"vi",
	"schinese":"zh",
	"tchinese":"zh",
}


# Set your game's Steam app IP
func _init() -> void:
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))


func _ready() -> void:
	# Initialize Steam
	var initialize_response: Dictionary = Steam.steamInit(false)
	print("[STEAM] Did Steam initialize?: %s" % initialize_response)
	if initialize_response['status'] != 1:
		is_steam_ok = false
		# If Steam fails to start up, shut down the app
		print("[STEAM] Failed to initialize Steam: %s" % initialize_response['verbal'])
		return
#		get_tree().quit()

	# Some example functions to run after initializing.
	# These can be deleted or commented out if not needed.
	#############################################
	#Is the user online?
	#is_online = Steam.loggedOn()

	# Get the user's Stean name and ID
	#steam_id = Steam.getSteamID()
	#steam_username = Steam.getPersonaName()

	# Is this app owned or is it a free weekend?
	#is_owned = Steam.isSubscribed()
	#is_free_weekend = Steam.isSubscribedFromFreeWeekend()

	# Is the game running on the Steam Deck
	#is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	var current_language = Steam.getCurrentGameLanguage()
	if current_language and language_to_locale_code.has(current_language):
		TranslationServer.set_locale(language_to_locale_code[current_language])
	is_steam_ok = true
	Steam.connect("current_stats_received", self, "_on_steam_stats_ready", [], CONNECT_ONESHOT)
	Steam.requestCurrentStats()


func _process(_delta: float) -> void:
	# Get callbacks
	Steam.run_callbacks()


func _on_steam_stats_ready(game: int, result: int, user: int) -> void:
	print("This game's ID: %s" % game)
	print("Call result: %s" % result)
	print("This user's Steam ID: %s" % user)


func increase_stat_by_1(stat_api_name:String):
	var current_stat = Steam.getStatInt(stat_api_name)
	var new_stat = current_stat + 1
	Steam.setStatInt(stat_api_name, new_stat)
	match stat_api_name:
		hole_in_one_stat_ach: #5
			if new_stat >= 5:
				Steam.storeStats()
		eagles_stat_ach: #10
			if new_stat >= 10:
				Steam.storeStats()
		birdies_stat_ach: #20
			if new_stat >= 20:
				Steam.storeStats()
		pars_stat_ach: #30
			if new_stat >= 30:
				Steam.storeStats()


func increase_snacks_stat(snacks_to_add:int):
	var current_snacks_eaten = Steam.getStatInt(snacks_eaten_api_name)
	var new_snacks_eaten = current_snacks_eaten + snacks_to_add
	Steam.setStatInt(snacks_eaten_api_name, new_snacks_eaten)


func increase_moves_made_stat(moves_to_add:int):
	var current_moves_made = Steam.getStatInt(moves_made_api_name)
	var new_moves_made = current_moves_made + moves_to_add
	Steam.setStatInt(moves_made_api_name, new_moves_made)


func unlock_achievement_by_level(level_nr: int) -> void:
	if is_steam_ok and achievements_dict.has(level_nr):
		var achievement = achievements_dict.get(level_nr)
		var WAS_SET: bool = Steam.setAchievement(achievement)
		print("Steam achievement "+str(achievement)+" set: "+str(WAS_SET))
		Steam.storeStats()
		

func unlock_achievement_by_name(name: String) -> void:
	if is_steam_ok:
		var WAS_SET: bool = Steam.setAchievement(name)
		print("Steam achievement "+str(name)+" set: "+str(WAS_SET))
		Steam.storeStats()


###
# Due to how GDNative works, the functions must either reside here or be called with Steam.Steam. since we are calling this singleton script then the Steamworks class.
###
