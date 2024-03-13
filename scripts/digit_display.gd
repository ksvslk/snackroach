extends Control

onready var label = $Label

var current_digit := 0


func _ready():
	label.text = str(current_digit)


func roll_digit(to: int):
	label.text = str(to)
	current_digit = to
