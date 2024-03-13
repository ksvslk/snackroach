extends VBoxContainer
onready var result = $Result
onready var score = $Score
onready var compliment = $Compliment


# info array
# 0. compliment (string)
# 1. codeword (string
# 2. play animation (int)
# 3. score (int)
func set_level_complete_info(info:Array):
	result.text = info[1]
	compliment.text = info[0]
	score.text = str(info[3]) + "pts"
	result.play_animation(info[2])
	
