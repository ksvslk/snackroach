extends Node2D

onready var roach = $KinematicCockroach
onready var final_point = $FinalPoint
onready var success_point = $SuccessPoint
var game_completed = false


func _ready():
	var crown_hat = "res://graphics/crown.png"
	roach.change_hat(crown_hat)
	GlobalSteam.unlock_achievement_by_name(GlobalSteam.crown_achievement)
	roach.state_machine.transition_to(
		C.success_State,
		{
			"points":[
				success_point.global_position,
				final_point.global_position]
		}
	)
	

func _process(delta):
	if not game_completed and roach.global_position.distance_to(final_point.global_position) <= 50:
		if roach.rotation_degrees < 90:
			roach.rotation += 1 * delta * 5
		else:
			game_completed = true
