extends Sprite

onready var red = $Red
onready var green = $Green

export(Color, RGBA) var off_color = Color("#00ff2b")
export(Color, RGBA) var on_color = Color("#ff0000")


func turn_off():
	green.visible = true
	red.visible = false
	modulate = off_color
	

func turn_on():
	green.visible = false
	red.visible = true
	modulate = on_color
