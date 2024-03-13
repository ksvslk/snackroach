extends TextureButton

onready var text = $Text
onready var sprite = $Sprite

export(String) var action_name
export(Texture) var icon


func _ready():
	sprite.texture = icon
	text.text = action_name
