extends Node

export(NodePath) var node_path
onready var node := get_node(node_path) as Node2D

	
func _ready():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	tween.set_loops(2)
	tween.chain().tween_property(node, "modulate:a", 0.7, 2).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(node, "modulate:a", 1.0, 2).set_ease(Tween.EASE_IN_OUT)
	tween.play()
