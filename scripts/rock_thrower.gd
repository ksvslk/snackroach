# rock_thrower.gd

extends Timer
class_name RockThrower

enum ThrowingMode {
	EXACTLY_AT_TARGET,
	TARGET_RADIUS,
	PREDEFINED_POINT_RADIUS,
	MULTIPLE_POINTS
}

export(ThrowingMode) var throwing_mode = ThrowingMode.EXACTLY_AT_TARGET
export var _target_node: NodePath

export(NodePath) var predefined_point_path
onready var _predefined_point: Position2D = get_node_or_null(predefined_point_path)

export(NodePath) var multiple_points_path
onready var _multiple_points: Node2D = get_node_or_null(multiple_points_path)

export(bool) var throwing_enabled: bool = true
export(float) var throw_completion_time: float
export(bool) var initial_delay: bool = false
export(float) var throwing_radius: float = 100.0
export(bool) var rythm_enabled: bool = false
export(int) var rythm_throwing_time
export(int) var rythm_pause_time


onready var throwing_time = $ThrowingTime
onready var pause_time = $PauseTime

onready var spawner := $Spawner2D as Position2D
onready var launch_position_left := $LaunchPositionLeft as Position2D
onready var launch_position_right := $LaunchPositionRight as Position2D
onready var target := get_node(_target_node) as KinematicCockroach
var impact_scene := load("res://scenes/Impact.tscn") as Resource
var impact = null


func _ready():
	if rythm_enabled:
		throwing_time.wait_time = rythm_throwing_time
		pause_time.wait_time = rythm_pause_time


func _on_ThrowingTime_timeout():
	stop_throwing()
	pause_time.start()


func _on_PauseTime_timeout():
	start_throwing()
	throwing_time.start()


func start_throwing():
	if throwing_enabled:
		if not initial_delay:
			_throw()
		start()
		if rythm_enabled:
			throwing_time.start()


func stop_throwing():
	stop()


func _throw():
	var spawn_pos: Vector2 = target.global_position
	match throwing_mode:
		ThrowingMode.EXACTLY_AT_TARGET:
			spawn_pos = target.global_position
		ThrowingMode.TARGET_RADIUS:
			spawn_pos = _get_random_point(target.global_position)
		ThrowingMode.PREDEFINED_POINT_RADIUS:
			spawn_pos = _get_random_point(_predefined_point.global_position)
		ThrowingMode.MULTIPLE_POINTS:
			var next = _multiple_points.get_children()[0]
			var child_count = _multiple_points.get_child_count()
			spawn_pos = next.global_position
			_multiple_points.move_child(next, child_count)
	_spawn_at_pos(spawn_pos)
	impact = spawner.spawn(spawn_pos, 0.0, false, true)


func _get_random_point(position: Vector2) -> Vector2:
	# center of the circle (x, y)
	var circle_x: float = position.x
	var circle_y: float = position.y
	# random angle
	var alpha: float = 2 * PI * randf()
	# random radius
	var r: float = throwing_radius * sqrt(randf())
	# calculating coordinates
	var x: float = r * cos(alpha) + circle_x
	var y: float= r * sin(alpha) + circle_y
	return Vector2(x,y)


func _spawn_at_pos(position: Vector2):
	if position.x < 540:
		spawner.global_position = launch_position_right.global_position
	else:
		spawner.global_position = launch_position_left.global_position
	var throwable: Node2D = spawner.spawn(position, throw_completion_time, true)
	throwable.connect("collision_check", self, "_add_impact_particles")


func _add_impact_particles(b_global_position: Vector2, overlapping_bodies: Array):
	var adjustable_tilemap: AdjustableTileMap
	var regular_tilemap: TileMap
	var honey_tilemap: Honey
	for ob in overlapping_bodies:
		if ob is BeamButton or ob is GateButton:
			ob.toggle_button()
		if ob is KinematicCockroach:
			if not ob.is_under_roof and not ob.shield_activated:
				impact.launch(b_global_position, target, Color(0,0,0,0), false, true)
				ob.state_machine.transition_to(C.smashed_state)
			elif ob.shield_activated:
				impact.launch(b_global_position, target, Color(0,0,0,0), true, target.is_under_roof)
		if ob is Spider or ob is TitanBeetle:
			if not ob.is_under_roof:
				GlobalSteam.unlock_achievement_by_name(GlobalSteam.rock_achievement)
				impact.launch(b_global_position, target, Color(0,0,0,0), false, true, target.is_under_roof)
				ob.state_machine.transition_to(C.smashed_state)
		elif ob is AdjustableTileMap:
			adjustable_tilemap = ob
		elif ob is Honey:
			honey_tilemap = ob
		elif ob is TileMap:
			regular_tilemap = ob
			
	if adjustable_tilemap:
		#impact.launch(b_global_position, target, Color.lightsteelblue, false, true)
		_add_fall_marks(adjustable_tilemap, b_global_position)
	elif honey_tilemap:
		impact.launch(b_global_position, target, Color.gold, false, false, target.is_under_roof)
	elif not adjustable_tilemap and regular_tilemap:
		_add_fall_marks(regular_tilemap, b_global_position)


func _add_fall_marks(ob: TileMap, b_global_position: Vector2, change_tiles = true):
	# set center cell
	var local_position: Vector2 = ob.to_local(b_global_position)
	var center_hit_cell: Vector2 = ob.world_to_map(local_position)
	
	var cell_random_choose: PoolIntArray = [121, 169]
	var rand_center_value: int = cell_random_choose[randi() % 2]
	
	# choose color for impact
	var impact_color: Color = Color(0,0,0,0)
	var always_ignore_cells: PoolIntArray = [-1, 17]
	
	if change_tiles:
		# set center cell
		var center_cell_id: int = ob.get_cellv(center_hit_cell)
		if not always_ignore_cells.has(center_cell_id) && ob.name != "Roof":
			if rand_center_value == 169:
				ob.set_cellv(center_hit_cell, 121)
			else:
				ob.set_cellv(center_hit_cell, rand_center_value)

		# set cross cells
		var cross: PoolVector2Array = [
			Vector2(center_hit_cell.x,center_hit_cell.y+1),
			Vector2(center_hit_cell.x,center_hit_cell.y-1),
			Vector2(center_hit_cell.x+1,center_hit_cell.y),
			Vector2(center_hit_cell.x-1,center_hit_cell.y)
		]
		for cell in cross:
			var cell_id: int = ob.get_cellv(cell)
			if cell_id == 198 or cell_id == 169:
				var cell_array: PoolIntArray = [121, 169]
				var rand_value: int = cell_array[randi() % 2]
				ob.set_cellv(cell, rand_value)

		# set first ring cells
		var first_ring: Dictionary = {
			192:Vector2(center_hit_cell.x-1,center_hit_cell.y-1),
			191:Vector2(center_hit_cell.x+1,center_hit_cell.y-1),
			187:Vector2(center_hit_cell.x+1,center_hit_cell.y+1),
			188:Vector2(center_hit_cell.x-1,center_hit_cell.y+1)
		}
		for cell in first_ring:
			var cell_pos: Vector2 = first_ring[cell]
			var cell_id: int = ob.get_cellv(cell_pos)
			if cell_id == 198 or cell_id == 169: 
				ob.set_cellv(cell_pos, cell)

		# set second ring cells
		var second_ring: Dictionary = {
			179:Vector2(center_hit_cell.x,center_hit_cell.y-2),
			180:Vector2(center_hit_cell.x,center_hit_cell.y+2),
			183:Vector2(center_hit_cell.x+2,center_hit_cell.y),
			184:Vector2(center_hit_cell.x-2,center_hit_cell.y)
		}
		for cell in second_ring:
			var cell_pos: Vector2 = second_ring[cell]
			if ob.get_cellv(cell_pos) == 198:
				ob.set_cellv(cell_pos, cell)
	
	impact.launch(b_global_position, target, impact_color, false, false, target.is_under_roof)
	
	
	
	
"""
Information about the tiles that will be changed on impact:
	center cross
	198 - SAND, sand
	169 - SAND with all dark corners, sand_all_dc
	121 - DiRT with all dark corners, dirt_all_dc

	first ring
	192 - SAND with missing topleft dark corner, sand_missing_tl_dc
	191 - SAND with missing topright dark corner, sand_missing_tr_dc
	187 - SAND with missing bottomright dark corner, sand_missing_br_dc
	188 - SAND with missing bottomleft dark corner, sand_missing_bl_dc

	second ring
	179 - SAND with dark downward corners, sand_dw_dc
	180 - SAND with dark upward corners, sand_uw_dc
	183 - SAND with dark rightward corners, sand_rw_dc
	184 - SAND with dark leftward corners, sand_lw_dc
"""
func old_add_fall_marks(ob: TileMap, b_global_position: Vector2, change_tiles = true):
	# set center cell
	var local_position: Vector2 = ob.to_local(b_global_position)
	var center_hit_cell: Vector2 = ob.world_to_map(local_position)
	
	var cell_random_choose: PoolIntArray = [121, 169]
	var rand_center_value: int = cell_random_choose[randi() % 2]
	
	# choose color for impact
	var impact_color: Color = _get_tile_color(Color(0,0,0,0), ob, center_hit_cell)
	var always_ignore_cells: PoolIntArray = [-1, 17]
	
	if change_tiles:
		# set center cell
		var center_cell_id: int = ob.get_cellv(center_hit_cell)
		if not always_ignore_cells.has(center_cell_id) && ob.name != "Roof":
			if rand_center_value == 169:
				ob.set_cellv(center_hit_cell, 121)
			else:
				ob.set_cellv(center_hit_cell, rand_center_value)

		# set cross cells
		var cross: PoolVector2Array = [
			Vector2(center_hit_cell.x,center_hit_cell.y+1),
			Vector2(center_hit_cell.x,center_hit_cell.y-1),
			Vector2(center_hit_cell.x+1,center_hit_cell.y),
			Vector2(center_hit_cell.x-1,center_hit_cell.y)
		]
		for cell in cross:
			var cell_id: int = ob.get_cellv(cell)
			impact_color = _get_tile_color(impact_color, ob, cell)
			if cell_id == 198 or cell_id == 169:
				var cell_array: PoolIntArray = [121, 169]
				var rand_value: int = cell_array[randi() % 2]
				ob.set_cellv(cell, rand_value)

		# set first ring cells
		var first_ring: Dictionary = {
			192:Vector2(center_hit_cell.x-1,center_hit_cell.y-1),
			191:Vector2(center_hit_cell.x+1,center_hit_cell.y-1),
			187:Vector2(center_hit_cell.x+1,center_hit_cell.y+1),
			188:Vector2(center_hit_cell.x-1,center_hit_cell.y+1)
		}
		for cell in first_ring:
			var cell_pos: Vector2 = first_ring[cell]
			impact_color = _get_tile_color(impact_color, ob, cell_pos)
			var cell_id: int = ob.get_cellv(cell_pos)
			if cell_id == 198 or cell_id == 169: 
				ob.set_cellv(cell_pos, cell)

		# set second ring cells
		var second_ring: Dictionary = {
			179:Vector2(center_hit_cell.x,center_hit_cell.y-2),
			180:Vector2(center_hit_cell.x,center_hit_cell.y+2),
			183:Vector2(center_hit_cell.x+2,center_hit_cell.y),
			184:Vector2(center_hit_cell.x-2,center_hit_cell.y)
		}
		for cell in second_ring:
			var cell_pos: Vector2 = second_ring[cell]
			impact_color = _get_tile_color(impact_color, ob, cell_pos)
			if ob.get_cellv(cell_pos) == 198:
				ob.set_cellv(cell_pos, cell)
	
	impact.launch(b_global_position, target, impact_color, false, false, target.is_under_roof)


func _get_tile_color(current_impact_color: Color, ob: TileMap, cell_pos: Vector2):
	if current_impact_color == Color(0,0,0,0):
		var color := Color(0,0,0,0)
		var tile_id: int = ob.get_cellv(cell_pos)
		if tile_id != -1:
			var texture: Texture = ob.tile_set.tile_get_texture(tile_id)
			if texture:
				var image: Image = texture.get_data()
				image.lock()
				color = image.get_pixel(16,16)
				image.unlock()
		return color
	return current_impact_color


func _on_RockThrower_timeout():
	_throw()



