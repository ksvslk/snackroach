extends Node2D

export(NodePath) var pos_nodepath
onready var particles := $CPUParticles2D as CPUParticles2D

func _ready():
	var position2d := get_node(pos_nodepath) as Position2D
	var target_position: Vector2 = position2d.global_position
	var angle: float = target_position.angle_to_point(particles.global_position)
	particles.global_rotation = 1.5 * PI + angle
