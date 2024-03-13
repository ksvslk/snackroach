extends DynamicFont


func _init():
	var size_addition = size / 5
	match(OS.get_locale_language()):
		"hi", "zh", "ar", "ja", "ko", "th":
			set_size(size + size_addition)
