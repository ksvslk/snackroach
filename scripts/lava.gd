extends TileMap


export(NodePath) var floor_path
export(bool) var auto_start = false
export(bool) var reverse_flow_direction = false
export(int) var speed_of_flow = 100
export(bool) var animate_lava_to_neutral = true
export(int) var how_many_tiles_to_increase_after_x_iteration = 0
export(int) var speed_up_tiles_amount_after_x_iteration = 3
export(int) var tiles_to_change = 10

onready var real_floor := get_node(floor_path)
onready var switch_glow = $ButtonArea/SwitchGlow
onready var switch = $ButtonArea/Switch
var tiles = []
var fun_tile_id = 306
var timer = 0
var counter = 0
var last_range_el_index = 0

var _lava_flowing = false

func _ready():
	tiles_to_change += 1
	if auto_start:
		let_the_lava_flow()
	switch_glow.turn_off()
	
	
func let_the_lava_flow():
	switch.play()
	if reverse_flow_direction:
		tiles = real_floor.original_tiles_positions
		tiles.invert()
	else:
		tiles = real_floor.original_tiles_positions
	_lava_flowing = true


func _animate_lava_to_neutral():
	if animate_lava_to_neutral:
		var tween := get_tree().create_tween()
		tween.tween_property(self, "modulate", Color("#5a000000"), 2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_callback(self, "_disable_collision")
		tween.play()


func _process(delta:float):
	timer += delta * speed_of_flow
	if timer > 10 and _lava_flowing:
		timer = 0
		var last_iteration = last_range_el_index + tiles_to_change > tiles.size()
		var tiles_range = range(last_range_el_index, last_range_el_index + tiles_to_change)
		if last_iteration:
			tiles_range = range(last_range_el_index, last_range_el_index + tiles.size() - last_range_el_index)
			_lava_flowing = false
			_animate_lava_to_neutral()
		for index in tiles_range:
			var tile = tiles[index]
			set_cellv(tiles[index], fun_tile_id)
		last_range_el_index = tiles_range.pop_back()
		counter += 1
		if counter == speed_up_tiles_amount_after_x_iteration:
			counter = 0
			tiles_to_change += how_many_tiles_to_increase_after_x_iteration


func _disable_collision():
	switch_glow.turn_off()
	set_collision_layer_bit(16, false)
	set_collision_mask_bit(12, false)
	set_collision_mask_bit(14, false)


func _on_ButtonArea_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if not _lava_flowing:
		switch_glow.turn_on()
		let_the_lava_flow()
