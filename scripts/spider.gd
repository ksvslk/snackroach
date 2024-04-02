class_name Spider, "res://graphics/icons/spider_node.svg"
extends KinematicBody2D

enum Tempo {
	STILL,
	VERY_SLOW,
	SLOW,
	SLOW_1,
	SLOW_2,
	SLOW_3,
	SLOW_4,
	SLOW_5,
	SLOW_6,
	SLOW_7,
	SLOW_8,
	NORMAL,
	MEDIUM
	FAST	
}


export var path_to_player := NodePath()
export(Tempo) var inital_tempo = Tempo.SLOW

onready var roach := get_node(path_to_player) as KinematicCockroach
onready var agent := $NavigationAgent2D as NavigationAgent2D

onready var actual_spider := $Wrapper/ActualSpider as Node2D
onready var circling_birds := $Wrapper/CirclingBirds as Node2D
onready var shader_node := $Wrapper/ActualSpider/Polygons as Node2D

onready var animation_player := $Wrapper/ActualSpider/Skeleton2D/AnimationPlayer as AnimationPlayer
onready var state_machine := $StateMachine as StateMachine
onready var walking_state := $StateMachine/Walking
onready var sword = $Wrapper/ActualSpider/Skeleton2D/Center/UpperBody/RLeg_1/RLeg_11/RLeg_111/Sword

var velocity := Vector2.ZERO
var pit_center := Vector2.ZERO
var is_under_roof := false
var is_dead := false
var legs_stuck := 0
var is_on_roof := false
export(bool) var red_light := false

signal debug_path_points(points)


func get_class():
	return "Spider"

func _ready():
	z_index = C.enemy_z_index
	

func _on_StateMachine_transitioned(new_state: String, previous_state: String):
	pass
	#print("SPIDER from ", previous_state, " to ", new_state)


func _on_LaserDetection_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if not is_dead:
		if area.name == "LaserArea":
			state_machine.transition_to(C.electrocuted_state)
			GlobalSteam.unlock_achievement_by_name(GlobalSteam.laser_achievement)
		if area.name == "Cockroach" and area.get_parent().are_eating_conditions_met() and is_ready_to_eat():
			state_machine.transition_to(C.eating_state)


func _intersects_wall() -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(global_position, roach.global_position, [self], self.collision_mask)
	if result:
		var tm = result["collider"] as TileMap
		if tm.name == "Wall":
			return true
	return false
	
	
func _on_Area2D_body_entered(_body):
	legs_stuck += 1
	_change_walking_and_animation_speed()


func _on_Area2D_body_exited(_body):
	legs_stuck -= 1
	_change_walking_and_animation_speed()


func _change_walking_and_animation_speed():
	if state_machine.state.name == C.walking_state:
		state_machine.state.adjust_walking_speed(legs_stuck)


func is_ready_to_eat() -> bool:
	return state_machine.state.name != C.fighting_state and not is_dead and not _intersects_wall()


func _on_LaserDetection_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if not is_dead:
		if body.name == "Obstacle" or (body.name == "Lava" and not is_on_roof):
			is_dead = true
			state_machine.transition_to(C.smashed_state)
			

func _on_LaserDetection_body_entered(body):
	if body.name == "Stairs" and not is_on_roof:
		is_on_roof = true
		z_index = C.roach_on_roof_z_index
		modulate.r += C.luminosity_while_on_roof
		modulate.g += C.luminosity_while_on_roof 
		modulate.b += C.luminosity_while_on_roof
		scale = Vector2(1.1, 1.1)


func _on_LaserDetection_body_exited(body):
	if body.name == "Stairs" and is_on_roof:
		is_on_roof = false
		z_index = C.enemy_z_index
		modulate.r -= C.luminosity_while_on_roof
		modulate.g -= C.luminosity_while_on_roof 
		modulate.b -= C.luminosity_while_on_roof
		scale = Vector2(1, 1)


func _on_TrafficLight_green_light():
	red_light = false

func _on_TrafficLight_red_light():
	red_light = true
