extends TileMap
class_name Snacks

var snacks_count: int = 0
var snack_cells := PoolVector2Array()
var minus_effect := preload("res://scenes/LostFood.tscn") as Resource
var eat_all_effect := preload("res://scenes/EatAllFood.tscn") as Resource
export(int) var snacks_tiles_range := 10
var snack_cells_size := 0


func init_snacks(count: int):
	snacks_count = count
	var used_cells = get_used_cells()
	randomize()
	for _i in range(0, snacks_count):
		var random_tile_name := C.snacks.keys()[randi() % C.snacks.size()] as String
		var final_tile := _generated_tile(random_tile_name) as Vector2
		while used_cells.has(final_tile):
			final_tile = _generated_tile(random_tile_name)
		snack_cells.append(final_tile)
		var transpose := randi() % 2
		var flip_x := randi() % 2
		var random_tile_id := tile_set.find_tile_by_name(random_tile_name) as int
		set_cellv(final_tile, random_tile_id, flip_x, false, transpose, Vector2( 0, 0 ))
	snack_cells_size = snack_cells.size()


func _generated_tile(random_tile_name: String) -> Vector2:
	var rand_x := randi() % snacks_tiles_range
	var rand_y := -1
	if random_tile_name == "bread" or random_tile_name == "cheese" or random_tile_name == "salad":
		rand_y = randi() % 1
	elif random_tile_name == "sausage" or random_tile_name == "bacon":
		rand_y = randi() % 2 + 1
	else:
		rand_y = randi() % 3 + 2
	return Vector2(rand_x, rand_y)


func get_snacks_count() -> int:
	return snack_cells.size()


func decrease_snacks():
	if not snack_cells.empty():
		var tile_to_remove: Vector2 = snack_cells[0]
		snack_cells.remove(0)
		snack_cells_size -= 1
		var effect = minus_effect.instance()
		var cell_id: int = get_cellv(tile_to_remove)
		if cell_id != -1:
			_SET_food_gradient(effect.color_ramp, cell_id)
		var global_pos: Vector2 = to_global(map_to_world(tile_to_remove))
		get_parent().add_child(effect)
		effect.global_position = global_pos
		set_cellv(tile_to_remove, -1)


func _SET_food_gradient(gradient, cell_id) -> void:
	var food_name = tile_set.tile_get_name(cell_id)
	var color = C.snacks.get(food_name)
	var second_color = color.lightened(0.5)
	second_color.a = 0.0
	gradient.set_color(1, second_color)
	gradient.set_color(0, color)


func eat_all_snacks():
	if snack_cells_size > 0:
		var effect = eat_all_effect.instance()
		_SET_all_food_gradient(effect.color_ramp)
		var global_pos = to_global(map_to_world(Vector2(7,2)))
		add_child(effect)
		effect.global_position = global_pos
		effect.one_shot = true
		effect.emitting = true


func _SET_all_food_gradient(gradient) -> void:
	var increase_step := 1.0 / snack_cells_size
	var current_step: float = 0.0
	var food_name = ""
	var color = Color()
	var tile_id = -1
	for i in snack_cells_size:
		tile_id = get_cellv(snack_cells[i])
		if tile_id != -1:
			set_cellv(snack_cells[i], -1)
			food_name = tile_set.tile_get_name(tile_id)
			color = C.snacks.get(food_name)
			gradient.add_point(current_step, color)
		current_step += increase_step
