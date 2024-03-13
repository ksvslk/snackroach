# enemy_walking_state.gd

extends EnemyState

onready var audio := $AudioStreamPlayer as AudioStreamPlayer
onready var timer = $Timer
var walking_speed := Vector2.ZERO
var animation_speed := 0


func set_tempo(tempo):
	match tempo:
		enemy.Tempo.STILL:
			walking_speed = Vector2(1, 1)
			animation_speed = 1
		enemy.Tempo.VERY_SLOW:
			walking_speed = Vector2(10, 10)
			animation_speed = 1
		enemy.Tempo.SLOW:
			walking_speed = Vector2(50, 50)
			animation_speed = 1
		enemy.Tempo.SLOW_1:
			walking_speed = Vector2(60, 60)
			animation_speed = 1
		enemy.Tempo.SLOW_2:
			walking_speed = Vector2(70, 70)
			animation_speed = 1
		enemy.Tempo.SLOW_3:
			walking_speed = Vector2(80, 80)
			animation_speed = 1
		enemy.Tempo.SLOW_4:
			walking_speed = Vector2(90, 90)
			animation_speed = 1
		enemy.Tempo.SLOW_5:
			walking_speed = Vector2(100, 100)
			animation_speed = 1
		enemy.Tempo.SLOW_6:
			walking_speed = Vector2(110, 110)
			animation_speed = 1
		enemy.Tempo.SLOW_6:
			walking_speed = Vector2(120, 120)
			animation_speed = 1
		enemy.Tempo.SLOW_7:
			walking_speed = Vector2(130, 130)
			animation_speed = 1
		enemy.Tempo.SLOW_8:
			walking_speed = Vector2(140, 140)
			animation_speed = 1
		enemy.Tempo.NORMAL:
			walking_speed = Vector2(150, 150)
			animation_speed = 2
		enemy.Tempo.MEDIUM:
			walking_speed = Vector2(320, 320)
			animation_speed = 3
		enemy.Tempo.FAST:
			walking_speed = Vector2(640, 640)
			animation_speed = 6


func adjust_walking_speed(legs_stuck: int):
	match legs_stuck:
		0:
			set_tempo(enemy.inital_tempo)
		1, 2:
			set_tempo(enemy.Tempo.NORMAL)
		3, 4:
			set_tempo(enemy.Tempo.SLOW)
		5, 6:
			set_tempo(enemy.Tempo.VERY_SLOW)
		7, 8:
			set_tempo(enemy.Tempo.VERY_SLOW)
	
	if enemy.legs_stuck >= 1:
		audio.pitch_scale = 3
		audio.volume_db = 10
	elif enemy.legs_stuck == 0:
		audio.pitch_scale = 1
		audio.volume_db = 5


func enter(_msg: Dictionary = {}) -> void:
	set_tempo(enemy.inital_tempo)
	timer.connect("timeout", self, "_update_pathfinding")
	enemy.animation_player.playback_speed = animation_speed
	enemy.animation_player.play(C.walking_animation)


func exit() -> void:
	timer.disconnect("timeout", self, "_update_pathfinding")


func physics_update(_delta: float) -> void:
	if enemy.red_light:
		enemy.state_machine.transition_to(C.idle_state)
	enemy.emit_signal("debug_path_points", enemy.agent.get_nav_path())
	if enemy.agent.is_navigation_finished():
		enemy.state_machine.transition_to(C.idle_state)
	var next_location = enemy.agent.get_next_location()
	var direction := enemy.global_position.direction_to(enemy.agent.get_next_location())
	enemy.velocity = direction * walking_speed
	enemy.look_at(next_location)
	var collision = enemy.move_and_collide(enemy.velocity * _delta)


func _update_pathfinding() -> void:
	enemy.agent.set_target_location(enemy.roach.global_position)

