extends Area2D

onready var switch_glow = $SwitchGlow
export(NodePath) var light_path
onready var light_2d := get_node_or_null(light_path)

export(NodePath) var spider_path = ""
onready var spider := get_node_or_null(spider_path) as Spider

var lights_on = false
export(bool) var light_stay_on = false
export(String) var chamber_name


func _on_GlobalLightSwitcher_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	#print("current lights on: ", lights_on)
	#print("change lights on: ", str(not lights_on))
	if not light_stay_on:
		switch_glow.turn_off()
		_animate_lights_on()
	else:
		lights_on = not lights_on
		if lights_on:
			#print("lights_on")
			if spider:
				spider.red_light = false
			switch_glow.turn_off()
			_animate_lights_on()
			_handle_chamber_entering()
		else:
			#print("not lights on")
			switch_glow.turn_on()
			_animate_lights_out()
			

func _handle_chamber_entering():
	if chamber_name == "Secret11":
		GlobalSteam.unlock_achievement_by_name(GlobalSteam.secret1_achievement)
		$ChamberEnteringSound.play()
	elif chamber_name == "Secret20":
		GlobalSteam.unlock_achievement_by_name(GlobalSteam.secret2_achievement)
		$ChamberEnteringSound.play()


func _on_GlobalLightSwitcher_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	#lights_on = not lights_on
	if not light_stay_on:
		switch_glow.turn_on()
		_animate_lights_out()


func _animate_lights_out():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(light_2d, "modulate:a", 1.0, 0.25)
	tween.play()


func _animate_lights_on():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(light_2d, "modulate:a", 0.0, 0.25)
	tween.play()

