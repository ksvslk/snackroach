# kinematic_cockroach.gd

class_name KinematicCockroach, "res://graphics/icons/hero_node.svg"
extends KinematicBody2D

onready var animation_player := $CockWrapper/Cockroach/Skeleton2D/AnimationPlayer as AnimationPlayer
onready var state_machine := $StateMachine as StateMachine
onready var walking_state := $StateMachine/Walking
onready var circling_birds := $CockWrapper/CirclingBirds as Node2D
onready var shield := $Shield as ColorRect
onready var shield_animation := $Shield/AnimationPlayer as AnimationPlayer
onready var shield_sound := $Shield/Sound as AudioStreamPlayer2D
onready var shader_node := $CockWrapper/Cockroach/Polygons
var flash_shader := load("res://shader/FlashMaterial.tres") as Resource

onready var shield_activated := false
onready var starting_position := global_position as Vector2
onready var starting_rotation := global_rotation as float

var temp_velocity := Vector2.ZERO

var velocity := Vector2.ZERO
var current_platform_velocity := Vector2.ZERO
onready var last_mouse_pos := Vector2.ZERO
onready var roach_size := (((get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D).radius / 2) as float

export var walking_speed := Vector2(640, 640)
onready var initial_walking_speed := walking_speed
export var animation_speed := 6
onready var initial_animation_speed := animation_speed

var is_on_roof := false
var is_under_roof := false
var is_on_moving_platform := false
var is_drunk := false
var legs_stuck := 0
var on_platform_count := 0
var foodgate_reached = false

var cursor_position = Vector2.ZERO

var belts: Array = []
signal dead
signal foodgate_touched


func _ready():
	z_index = C.roach_z_index
	var current_hat_path = Data.get_hat_path()
	change_hat(current_hat_path)


func change_hat(new_hat:String):
	if new_hat == "res://graphics/hats/no_hat.png":
		get_node("CockWrapper/Cockroach/Hat").texture = null
	else:
		get_node("CockWrapper/Cockroach/Hat").texture = load(new_hat)


func activate_shield():
	if not shield_activated:
		shield_sound.play()
		shield_activated = true
		shield.visible = true
		shield_animation.play("ACTIVE")


func deactivate_shield():
	shield_activated = false
	shield.visible = false
	
	
func _on_StateMachine_transitioned(new_state: String, previous_state: String):
	#print("COCKROACH from ", previous_state, " to ", new_state)
	if new_state == C.smashed_state and not foodgate_reached:
		emit_signal("dead")


func _on_TapArea_gui_input(event: InputEvent):
	if not foodgate_reached:
		state_machine.state.handle_input(event)


func enter_drunk_walking():
	if state_machine.state.name == C.walking_state:
		state_machine.transition_to(C.drunk_walking_state)


func exit_drunk_walking():
	if state_machine.state.name == C.drunk_walking_state:
		state_machine.transition_to(C.walking_state)


func _on_AnimationPlayer_animation_finished(_anim_name: String):
	deactivate_shield()


func cover():
	activate_shield()


func _on_Area2D_body_entered(_body):
	legs_stuck += 1
	_change_walking_and_animation_speed()


func _on_Area2D_body_exited(_body):
	if legs_stuck > 0:
		legs_stuck -= 1
	_change_walking_and_animation_speed()


func _change_walking_and_animation_speed():
	match legs_stuck:
		0:
			walking_speed = initial_walking_speed
			animation_speed = initial_animation_speed
		1:
			walking_speed = Vector2(initial_walking_speed.x / 2, initial_walking_speed.y / 2)
			animation_speed = 3
		2:
			walking_speed = Vector2(initial_walking_speed.x / 6, initial_walking_speed.y / 6)
			animation_speed = 2
		3:
			walking_speed = Vector2(initial_walking_speed.x / 7, initial_walking_speed.y / 7)
			animation_speed = 2
		4:
			walking_speed = Vector2(initial_walking_speed.x / 8, initial_walking_speed.y / 8)
			animation_speed = 1
		5:
			walking_speed = Vector2(initial_walking_speed.x / 10, initial_walking_speed.y / 10)
			animation_speed = 1
		6:
			walking_speed = Vector2(1, 1)
			animation_speed = 1
	
	if state_machine.state.name == C.walking_state:
		state_machine.state.adjust_walking_speed()

# 0 belts - current belt is the belt added
# >=1 belt - current belt cannot be tset here
func enter_to_moving_belt(belt):
	if state_machine.state.name != C.success_State and belt.activated:
		belts.append(belt)
		on_platform_count += 1
		if belts.size() == 1:
			is_on_moving_platform = true
			current_platform_velocity = belt.get_platform_velocity()
			if state_machine.state.name != C.walking_state:
				velocity = current_platform_velocity
			else:
				velocity += current_platform_velocity
			if state_machine.state.name != C.walking_state:
				state_machine.transition_to(C.moving_state)


# 0 belts - current belt is null
# 1 belt - current belt is the belt that is there
# >= 1 belt
func exit_from_moving_belt(belt):
	if state_machine.state.name != C.success_State and belt.activated:
		belts.erase(belt)
		on_platform_count -= 1
		if belts.size() == 1:
			if state_machine.state.name == C.walking_state:
				velocity += belts[0].get_platform_velocity()
				current_platform_velocity = belts[0].get_platform_velocity()
			else:
				velocity = belts[0].get_platform_velocity()
				current_platform_velocity = velocity
		if on_platform_count == 0:
			is_on_moving_platform = false
			current_platform_velocity = Vector2.ZERO
			if state_machine.state.name != C.walking_state and state_machine.state.name != C.smashed_state:
				state_machine.transition_to(C.idle_state)


func _on_Cockroach_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if not foodgate_reached:
		if area.name == "Snack":
			foodgate_reached = true
			emit_signal("foodgate_touched")
		if area is SpikesSquare and not shield_activated:
			state_machine.transition_to(C.smashed_state)
		if area.name == "LaserArea" and not shield_activated:
			electrocute()
		if area.name == "LaserDetection" and are_eating_conditions_met() and area.get_parent().is_ready_to_eat() and not shield_activated:
			if state_machine.state.name != C.smashed_state:
				state_machine.transition_to(C.smashed_state)


func electrocute():
	shader_node.material = flash_shader
	yield(get_tree().create_timer(0.1), "timeout")
	shader_node.material = null
	state_machine.transition_to(C.smashed_state)


func are_eating_conditions_met() -> bool:
	return state_machine.state.name != C.cover_state


func _on_Cockroach_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if state_machine.state.name != C.smashed_state and not foodgate_reached:
		if body.name == "Obstacle" and not shield_activated:
			body.get_parent().set_physics_process(false) 
			state_machine.transition_to(C.smashed_state)
		elif body.name == "Lava" and not is_on_roof and not shield_activated:
			body.get_parent().set_physics_process(false) 
			state_machine.transition_to(C.smashed_state)


func _on_Cockroach_body_entered(body):
	if not foodgate_reached:
		if body is SpikesSquare and not shield_activated:
			body.get_parent().set_physics_process(false) 
			state_machine.transition_to(C.smashed_state)
		if body.name == "Alcohol" and not shield_activated:
			is_drunk = true
			enter_drunk_walking()
		if body.name == "Stairs" and not is_on_roof:
			is_on_roof = true
			z_index = C.roach_on_roof_z_index
			modulate.r += C.luminosity_while_on_roof
			modulate.g += C.luminosity_while_on_roof 
			modulate.b += C.luminosity_while_on_roof
			scale = Vector2(1.3, 1.3)


func _on_Cockroach_body_exited(body):
	if not foodgate_reached:
		if body.name == "Alcohol":
			is_drunk = false
			exit_drunk_walking()
		if body.name == "Stairs" and is_on_roof:
			is_on_roof = false
			z_index = C.roach_z_index
			modulate.r -= C.luminosity_while_on_roof
			modulate.g -= C.luminosity_while_on_roof 
			modulate.b -= C.luminosity_while_on_roof
			scale = Vector2(1.2, 1.2)
