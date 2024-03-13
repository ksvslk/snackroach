# debug_draw.gd

extends Control

onready var player := get_parent().get_parent().get_node("KinematicCockroach") as KinematicCockroach
var width: int = 2
export(Color) var color := Color(0, 1, 0)
export(Color) var color2 := Color(0, 1, 0)


func _process(delta: float):
	if not visible:
		return
	update()


func _draw():
	_draw_cockroach_position()
	_draw_vector()
	_draw_vector(5, color2)


func _draw_vector(factor: int = 1, my_color: Color = color):
	var start := player.global_transform.origin as Vector2
	var end := (player.global_transform.origin + player.velocity / factor) as Vector2
	draw_line(start, end, my_color, width)
	draw_triangle(end, start.direction_to(end), width*2, my_color)


func _draw_cockroach_position():
	draw_circle(player.last_mouse_pos, 10, color)


func draw_triangle(pos: Vector2, dir: Vector2, size: int, color:Color):
	var a := (pos + dir * size) as Vector2
	var b := (pos + dir.rotated(2*PI/3) * size) as Vector2 
	var c := (pos + dir.rotated(4*PI/3) * size) as Vector2
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
