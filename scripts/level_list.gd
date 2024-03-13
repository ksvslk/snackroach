extends GridContainer

var levels = []
#func _ready():
#	var path = "res://levels"
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if file_name.get_extension() == "tscn":
#				levels.append(int(file_name.get_basename()))
#			file_name = dir.get_next()
#	else:
#		#print("An error occurred when trying to access the path.")
#	levels.sort()
#	for level in levels:
#		var b := button.instance() as LinkButton
#		b.text = "LEVEL " + str(level)
#		b.connect("pressed", self, "_start_level", [level])
#		add_child(b)
#
#
#func _start_level(nr: int):
#	get_parent().get_parent()._start_next_level(nr)
#	visible = false


func _on_SettingsButton_pressed():
	visible = !visible
