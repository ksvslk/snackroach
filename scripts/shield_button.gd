extends Button

enum ButtonState {
	ACTION,
	AD,
	IN_PROGRESS
}

export(ButtonState) var state
export(NodePath) var top_master_path: NodePath
onready var top_master := get_node(top_master_path) as Master
onready var shield_button = $Graphics/ShieldButton
onready var reward_button = $Graphics/RewardButton
onready var reward_text = $Graphics/RewardText
onready var number_roller = $NumberRoller
onready var graphics = $Graphics


func _ready():
	Data.connect("shield_amount_changed", self, "_change_shields_amount")
	Data.send_shields_amount_to_ui()


func _change_shields_amount(new_amount: int):
	var ad_loaded = false
	if new_amount > 0:
		number_roller.roll(new_amount)
		change_state_to(C.ButtonState.ACTION)
	elif ad_loaded:
		change_state_to(C.ButtonState.AD)
	elif not ad_loaded:
		change_state_to(C.ButtonState.IN_PROGRESS)
	
	
func change_state_to(new_state: int):
	match new_state:
		ButtonState.ACTION:
			mouse_filter = MOUSE_FILTER_STOP
			graphics.modulate.a = 1.0
			reward_button.visible = false
			reward_text.visible = false
			number_roller.visible = true
			state = new_state
		ButtonState.AD:
			mouse_filter = MOUSE_FILTER_STOP
			graphics.modulate.a = 1.0
			reward_button.visible = true
			reward_text.visible = true
			number_roller.visible = false
			state = new_state
		ButtonState.IN_PROGRESS:
			mouse_filter = MOUSE_FILTER_IGNORE
			graphics.modulate.a = 0.2
			reward_button.visible = false
			reward_text.visible = false
			number_roller.visible = false
			state = new_state


func _execute_action() -> bool:
	var current_state := top_master.level.get_current_state() as String
	if not top_master.level.is_shield_activated() and current_state != C.smashed_state:
		top_master.level.roach.cover()
		return true
	return false
	
	
func  _rewarded_video_opened():
	if state == ButtonState.AD:
		change_state_to(ButtonState.IN_PROGRESS)


func _on_rewarded_video_loaded():
	if state == ButtonState.IN_PROGRESS:
		change_state_to(ButtonState.AD)


func _rewarded(_currency, amount:int , action: int):
	if action == C.Actions.COVER:
		Data.increase_shields_by(amount)
		#load_rewarded()


func _on_ShieldButton_pressed():
	if state == ButtonState.ACTION:
		if _execute_action():
			Data.decrease_shields()
		elif state == ButtonState.AD:
			change_state_to(ButtonState.IN_PROGRESS)
