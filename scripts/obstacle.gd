tool
extends Node2D
class_name Obstacle, "res://graphics/icons/obstacle_node.svg"

onready var kinematic = $Obstacle
onready var end_position = $EndPosition
onready var start_position = $StartPosition
onready var switch = $Switch
onready var switch_button = $ButtonArea/SwitchButton

enum Move {
	NONE,
	LINEAR,
	ONE_SHOT_ROTATION,
	CLOCKWISE_ROTATION,
	COUNTER_CLOKCWISE_ROTATION
}

export(float) var speed
export(Move) var move = Move.NONE setget _make_adjustments

onready var start_rotation = kinematic.rotation_degrees
export(float) var end_rotation
export(bool) var loop = false

export(bool) var run_editor_code = false

export var switch_on_roof := false
export(bool) var switch_enabled := false setget _toggle_switch_visibility
export var platform_moving := true

export var path_to_player := NodePath()
onready var roach := get_node(path_to_player) as KinematicCockroach

onready var current_target_position = end_position.global_position
onready var current_target_rotation = end_rotation


func _toggle_switch_visibility(new_state):
	switch_enabled = new_state
	var bt = $ButtonArea as Area2D
	bt.visible = new_state
	bt.monitorable = new_state
	bt.monitoring = new_state


func _make_adjustments(new_move):
	var line_left = $LeftLine
	var line_right = $RightLine
	var main_start_circle = $Obstacle/Line2D/StartPortal
	var main_end_circle = $Obstacle/Line2D/EndPortal
	
	match new_move:
		Move.NONE:
			move = new_move
			line_left.visible = false
			line_right.visible = false
			main_start_circle.visible = false
			main_end_circle.visible = false
		Move.LINEAR:
			move = new_move
			line_left.visible = true
			line_right.visible = true
			main_start_circle.visible = true
			main_end_circle.visible = true
		Move.ONE_SHOT_ROTATION:
			move = new_move
			line_left.visible = false
			line_right.visible = false
			main_start_circle.visible = true
			main_end_circle.visible = false
		Move.CLOCKWISE_ROTATION:
			move = new_move
			line_left.visible = false
			line_right.visible = false
			main_start_circle.visible = true
			main_end_circle.visible = false
		Move.COUNTER_CLOKCWISE_ROTATION:
			move = new_move
			line_left.visible = false
			line_right.visible = false
			main_start_circle.visible = true
			main_end_circle.visible = false


func _physics_process(delta:float) -> void:
	if not Engine.editor_hint and platform_moving and roach.state_machine.state.name != C.smashed_state:
		if move == Move.LINEAR and kinematic.global_position.distance_squared_to(current_target_position) > 50.0:
			kinematic.move_and_slide(kinematic.global_position.direction_to(current_target_position) * speed)
		elif move == Move.LINEAR and loop and kinematic.global_position.distance_squared_to(current_target_position) <= 50.0:
			if current_target_position == start_position.global_position:
				current_target_position = end_position.global_position
			else:
				current_target_position = start_position.global_position
				
		elif move == Move.ONE_SHOT_ROTATION and loop:
			if kinematic.rotation_degrees >= end_rotation:
				current_target_rotation = start_rotation
			elif kinematic.rotation_degrees <= start_rotation:
				current_target_rotation = end_rotation
		elif move == Move.ONE_SHOT_ROTATION and not loop:
			if kinematic.rotation_degrees >= end_rotation:
				move  = Move.NONE
			
		if move == Move.ONE_SHOT_ROTATION:
			if current_target_rotation == end_rotation:
				kinematic.rotation += speed * delta
			elif current_target_rotation == start_rotation and loop:
				kinematic.rotation -= speed * delta
				
		elif move == Move.CLOCKWISE_ROTATION:
			kinematic.rotation += speed * delta
		elif move == Move.COUNTER_CLOKCWISE_ROTATION:
			kinematic.rotation -= speed * delta


func _process(_delta:float) -> void:	
	if Engine.editor_hint and run_editor_code:
		var spikes_top = $Obstacle/SpikesTop
		var spikes_bottom = $Obstacle/SpikesBottom
		var line_2d = $Obstacle/Line2D
		var start_point = line_2d.points[0]
		var end_point = line_2d.points[line_2d.points.size() - 1]
		var width = end_point.x - start_point.x
		spikes_top.region_rect = Rect2(spikes_top.region_rect.position, Vector2(width, spikes_top.region_rect.size.y))
		spikes_bottom.region_rect = Rect2(spikes_bottom.region_rect.position, Vector2(width, spikes_bottom.region_rect.size.y))
		var col = get_node("Obstacle/CollisionShape2D")
		var dist = abs(start_point.x-end_point.x)/2
		col.position.x = dist
		col.shape.height = 1.6 * dist
		$RightLine.position.x = 2 * dist


func _toggle_obstacle_state():
	platform_moving = !platform_moving
	switch.play()
	if platform_moving:
		switch_button.turn_on()
	else:
		switch_button.turn_off()


func _on_ButtonArea_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if switch_on_roof and area.name == "Cockroach" and area.get_parent().is_on_roof:
		_toggle_obstacle_state()
	elif not switch_on_roof:
		_toggle_obstacle_state()
