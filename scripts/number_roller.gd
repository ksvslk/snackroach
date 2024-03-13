extends HBoxContainer

var current_value = 0
export var _digit: PackedScene


func roll(nr: int):
	_clean_up()
	current_value = nr
	var number_string = str(nr)
	var length_of_number = number_string.length() 
	for index in range(length_of_number):
		var ch = number_string[index]
		var next_digit_roller := _digit.instance()
		add_child(next_digit_roller)
		next_digit_roller.roll_digit(int(ch))


func _clean_up():
	for child in get_children():
		child.queue_free()


func adjust_number(nr: int):
	var child_count = get_child_count()
	var number_length = str(nr).length()
	for index in range(number_length):
		if index + 1  > child_count:
			var next_digit_roller := _digit.instance()
			add_child(next_digit_roller) 
			next_digit_roller.roll_digit(int(str(nr)[index]))
		else:
			get_child(index).roll_digit(int(str(nr)[index]))
