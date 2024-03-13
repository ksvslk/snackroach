extends HBoxContainer
class_name ScoreLine

onready var roach = $Roach
onready var rank = $Rank

export(String, MULTILINE) var player_text = "PlayerBlaBlaBla24\n 2304 points"
export(String, MULTILINE) var rank_text
export(Color) var stylebox_color
export(Color) var font_color


func _ready():
	var style = roach.get("custom_styles/normal")
	var rank_style = rank.get("custom_styles/normal")
	roach.set("custom_colors/font_color", font_color)
	rank_style.bg_color = stylebox_color
	rank_style.bg_color.a -= 0.1
	rank.set("custom_colors/font_color", font_color)
	style.bg_color = stylebox_color
	style.bg_color.a -= 0.1
	roach.text = player_text
	rank.text = rank_text

