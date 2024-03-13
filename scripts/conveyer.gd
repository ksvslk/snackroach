extends Area2D
class_name Conveyer, "res://graphics/icons/belt_node.svg"

onready var texture_rect = $TextureRect

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export(Direction) var direction = Direction.UP
export(bool) var activated = true setget set_activate
export(int) var speed = 2
const divider := 50

func _ready():
	texture_rect.material.set("shader_param/speed", speed / divider) 


func get_platform_velocity() -> Vector2:
	match direction:
		Direction.UP:
			return Vector2(0, -speed)
		Direction.DOWN:
			return Vector2(0, speed)
		Direction.LEFT:
			return Vector2(-speed, 0)
		Direction.RIGHT:
			return Vector2(speed, 0)
	return Vector2.ONE
	
	
func _on_Conveyer_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicCockroach:
		#print("Exited: ", self.name)
		body.exit_from_moving_belt(self)


func _on_Conveyer_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is KinematicCockroach:
		#print("Entered: ", self.name)
		body.enter_to_moving_belt(self)


func set_activate(b: bool):
	activated = b
	set_process(b)
	if b:
		texture_rect.material.set("shader_param/speed", speed / divider) 
	else:
		texture_rect.material.set("shader_param/speed", 0.0)
