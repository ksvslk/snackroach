extends Area2D
class_name Roof, "res://graphics/icons/roof_node.svg"

onready var collision_shape := $CollisionShape2D as CollisionShape2D

func _ready():
	z_index = C.shelter_z_index
