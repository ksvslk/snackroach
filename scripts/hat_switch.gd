extends Control

var current_content_index = 0
var contents = [
	"res://graphics/hats/no_hat.png",
	"res://graphics/hats/christmas.png",
	"res://graphics/hats/mexican.png",
	"res://graphics/hats/cap.png",
	"res://graphics/hats/chef.png",
	"res://graphics/hats/turban.png",
	"res://graphics/hats/military.png",
	"res://graphics/hats/sun.png",
	"res://graphics/hats/pilot.png",
	"res://graphics/hats/vietnam.png",
	"res://graphics/hats/cowboy.png",
	"res://graphics/hats/jew.png",
	"res://graphics/hats/fire.png",
	"res://graphics/hats/beanie.png",
	"res://graphics/hats/dragon.png",
	"res://graphics/hats/party.png",
]

onready var selected_hat = $SelectedHat
onready var previous = $Previous
onready var next = $Next

func _ready():
	var current_hat_path = Data.get_hat_path()
	current_content_index = contents.find(current_hat_path)
	selected_hat.texture = load(contents[current_content_index])
	_change_buttons_visibility()


func _change_buttons_visibility():
	previous.modulate.a = 1
	next.modulate.a = 1
	previous.disabled = false
	next.disabled = false
	if current_content_index == 0:
		previous.disabled = true
		previous.modulate.a = 0.15
	if current_content_index == contents.size() - 1:
		next.disabled = true
		next.modulate.a = 0.15
		


func update_content():
	if contents[current_content_index] != "":
		selected_hat.texture = load(contents[current_content_index])
	else:
		selected_hat.texture = null
	Data.set_hat_path(contents[current_content_index])
	_change_buttons_visibility()


func _on_Previous_pressed():
	current_content_index = max(current_content_index - 1, 0)
	update_content()


func _on_Next_pressed():
	current_content_index = min(current_content_index + 1, contents.size() - 1)
	update_content()
