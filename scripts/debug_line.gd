extends Line2D

export var enemy_path_shown := true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)


func _on_Spider_debug_path_points(path_points):
	clear_points()
	if enemy_path_shown:
		for p in path_points:
			add_point(to_local(p))
	

