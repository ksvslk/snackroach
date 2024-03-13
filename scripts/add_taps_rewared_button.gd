extends Button
onready var color_rect = $ColorRect

var should_show_button = false

export(Texture) var android_icon
export(Texture) var iphone_icon

export(String) var android_text
export(String) var iphone_text

func _activate_button():
	color_rect.rect_size.y = rect_size.y + 110
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(color_rect, "rect_size:x", 1430.0, 0.7)
	tween.tween_property(self, "self_modulate:a", 1.0, 0.4)
	tween.tween_callback(self, "set_mouse_filter", [Control.MOUSE_FILTER_STOP])
	tween.play()


func _reset_button():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.rect_size.x = 150
	self_modulate.a = 0.0


func _ready():
	if OS.get_name() == "Android" && !C.is_amazon:
		text = android_text
		icon = android_icon
		GPack.android_plugin.connect(GPack.s_rewarded_ad_loaded, self,  "_ad_loaded")
		GPack.android_plugin.connect(GPack.s_rewarded_ad_failed_to_load, self, "_ad_failed_to_load")
	elif OS.get_name() == "iOS":
		icon = iphone_icon
		text = iphone_text


func activate_button_when_conditions_met():
	if OS.get_name() == "Android":
		if GPack.is_rewarded_ad_loaded():
			_reset_button()
			visible = true
			_activate_button()
			should_show_button = false
		else:
			should_show_button = true
			GPack.load_rewarded_ad()
	elif OS.get_name() == "iOS":
		_reset_button()
		visible = true
		_activate_button()
		should_show_button = false


func _ad_loaded():
	if should_show_button:
		_reset_button()
		visible = true
		_activate_button()
		should_show_button = false


func _ad_failed_to_load(_msg):
	visible = false
	should_show_button = false
	
	

