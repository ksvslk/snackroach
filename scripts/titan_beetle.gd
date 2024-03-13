class_name TitanBeetle, "res://graphics/icons/beetle_node.svg"
extends KinematicBody2D

export var path_to_player := NodePath()
export var checkpoints_nodepath := NodePath()
onready var checkpoints: Array = []
onready var roach := get_node(path_to_player) as KinematicCockroach

onready var actual_titan_beetle = $Wrapper/TitanBeetle
onready var circling_birds = $Wrapper/CirclingBirds
onready var shader_node = $Wrapper/TitanBeetle/Polygons

onready var state_machine := $StateMachine as StateMachine
onready var animation_player = $Wrapper/TitanBeetle/Skeleton2D/AnimationPlayer

onready var sword = $Wrapper/TitanBeetle/Skeleton2D/RightLeg/RightLegT/RightLegC/Sword

export var animation_speed := 1
export var walking_speed := Vector2(100, 100)
export var loop_checkpoints := false
var checkpoints_passed = 0

var velocity := Vector2.ZERO
var is_under_roof := false
var is_dead := false

func get_class():
	return "TitanBeetle"


func _ready():
	checkpoints = get_node(checkpoints_nodepath).get_children()
	z_index = C.enemy_z_index


func get_current_checkpoint() -> Vector2:
	return checkpoints[0].global_position


func set_next_checkpoint() -> void:
	checkpoints.push_back(checkpoints.pop_front())
	if loop_checkpoints:
		checkpoints_passed += 1
		if checkpoints_passed == checkpoints.size():
			checkpoints.invert()
			checkpoints_passed = 0
	
	
func _on_StateMachine_transitioned(new_state: String, previous_state: String):
	pass
	#print("BEETLE from ", previous_state, " to ", new_state)


func _on_LaserDetection_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if not is_dead:
		if area.name == "LaserArea":
			is_dead = true
			state_machine.transition_to(C.electrocuted_state)
			Data.add_regular_achievement(C.achievement_neutralized_with_laser)
		elif area.name == "Cockroach" and area.get_parent().are_eating_conditions_met() and is_ready_to_eat():
			state_machine.transition_to(C.eating_state)
		elif area.name == "LaserDetection" and area.get_parent().get_class() != "TitanBeetle":
			state_machine.transition_to(C.fighting_state, { "opponent_position":area.get_parent().global_position, "opponenet_rotation":area.get_parent().global_rotation })
			area.get_parent().state_machine.transition_to(C.fighting_state, { "opponent_position":global_position, "opponenet_rotation":global_rotation })
			Data.add_regular_achievement(C.achievement_start_a_fight)


func _on_LaserDetection_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if not is_dead:
		if body.name == "Obstacle" or body.name == "Lava":
			is_dead = true
			state_machine.transition_to(C.smashed_state)


func _intersects_wall() -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(global_position, roach.global_position, [self], self.collision_mask)
	#C.draw_line(global_position, roach.global_position)
	if result:
		var tm = result["collider"] as TileMap
		if tm.name == "Wall":
			return true
	return false
	

func is_ready_to_eat() -> bool:
	return state_machine.state.name != C.fighting_state and not is_dead and not _intersects_wall()
