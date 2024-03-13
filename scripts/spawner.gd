extends Position2D

export var _rock: PackedScene
export var _impact: PackedScene

func spawn(end_position := Vector2.ZERO, spawn_animation_time: float = 0.0, spawn_rock = true, spawn_impact = false) -> Node2D:
	var spawn_scene = null
	if spawn_rock:
		spawn_scene = _rock
	elif spawn_impact:
		spawn_scene = _impact
	# Creates a new instance of the _spawn_scene
	var scene := spawn_scene.instance() as Node2D
	if scene is ThrowableNode:
		scene.animation_time = spawn_animation_time
		scene.end_position = end_position
	elif scene is Impact:
		scene.one_shot = true
		scene.emitting = false
		
	#call_deferred("add_child", scene)#
	add_child(scene)
	# Prevents the Spawner2D transform from affecting the new instance
	scene.set_as_toplevel(true)
	
	# Move the new instance to the Spawner2D position
	if scene is ThrowableNode:
		scene.start_position = global_position
		scene.global_position = global_position
		scene.z_index = C.rock_z_index
	elif scene is Impact:
		scene.z_index = C.impact_z_index
		scene.global_position = end_position
	else:
		scene.global_position = global_position
	return scene

