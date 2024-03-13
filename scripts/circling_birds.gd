extends Node2D

export(int) var speed: int = 3

func _process(delta: float):
	rotation += delta * speed
