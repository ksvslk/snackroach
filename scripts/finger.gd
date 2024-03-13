extends Node2D

onready var hand = $Hand
export(float, 0.0, 1.0, 0.05) var scale_percentage = 0.25
export(float, 0.0, 5.0, 0.05) var in_duration = 0.5
export(float, 0.0, 5.0, 0.05) var out_duration = 0.5

func _ready():
	var initial_scale = hand.scale
	var scale_to = initial_scale * scale_percentage
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(hand, "scale", scale_to, in_duration)
	tween.chain().tween_property(hand, "scale", initial_scale, out_duration)
	tween.set_loops(100000)
	tween.play()
