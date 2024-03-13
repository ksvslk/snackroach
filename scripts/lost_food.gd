extends CPUParticles2D


onready var audio := $Audio as AudioStreamPlayer2D

func _ready():
	one_shot = true
	emitting = true
	audio.play()
