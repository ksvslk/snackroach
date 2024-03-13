class_name Checkpoint
extends Area2D


onready var audio = $Audio
onready var hand = $Hand
export(float, 0.0, 1.0, 0.05) var scale_percentage = 0.8
export(float, 0.0, 5.0, 0.05) var in_duration = 0.5
export(float, 0.0, 5.0, 0.05) var out_duration = 0.5

export var path_to_next_checkpoint := NodePath()
var _next_checkpoint = null

export var node_to_show_path := NodePath()
var _node_to_show = null

func _ready():
	if path_to_next_checkpoint:
		_next_checkpoint = get_node(path_to_next_checkpoint)
	if node_to_show_path:
		_node_to_show = get_node(node_to_show_path)
	var initial_scale = hand.scale
	var scale_to = initial_scale * scale_percentage
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(hand, "scale", scale_to, in_duration)
	tween.chain().tween_property(hand, "scale", initial_scale, out_duration)
	tween.set_loops(100000)
	tween.play()


func _on_Checkpoint_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _next_checkpoint:
		_next_checkpoint.set_deferred("monitoring", true)
		_next_checkpoint.set_deferred("monitorable", true)
		_next_checkpoint.visible = true
	if _node_to_show:
		_node_to_show.visible = true
	audio.play()
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(self, "_free_me")
	tween.play()
	
	
func _free_me():
	queue_free()
