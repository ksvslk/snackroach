extends ThrowableNode

const THROWABLE_BIT: int = 2
var time_passed: float = 0.0
var thrown_into_pit: bool = false
onready var animated_sprite := $AnimatedSprite as AnimatedSprite
signal collision_check


func _ready():
	modulate.a = 0.1
	z_index = C.rock_z_index
	#throw_sound.play()


func _physics_process(delta: float):
	if scale.x < 0.05:
		queue_free()
	if time_passed < animation_time:
		if time_passed < animation_time / 2:
			scale += Vector2(0.1, 0.1)
		else:
			modulate.a += 0.01
			scale -= Vector2(0.1, 0.1)
		time_passed += delta
		var weight: float = time_passed / animation_time
		global_position = start_position.linear_interpolate(end_position, weight)
	else:
		if get_collision_layer_bit(THROWABLE_BIT) == false:
			animated_sprite.speed_scale = 4
			set_collision_layer_bit(THROWABLE_BIT, true)
			var overlapping_bodies: Array = get_overlapping_bodies()
			if not overlapping_bodies.empty():
				emit_signal("collision_check", global_position, overlapping_bodies)
			else:
				thrown_into_pit = true
		if thrown_into_pit:
			scale = scale.linear_interpolate(scale - Vector2(6.0, 6.0), delta)
			modulate = modulate.darkened(6.0 * delta)
		else:
			global_position = global_position.linear_interpolate(Vector2(global_position.x, global_position.y + 1200), delta)


func _on_VisibilityNotifier2D_screen_exited():
	if not time_passed < animation_time:
		queue_free()
