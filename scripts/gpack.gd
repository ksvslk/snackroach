extends Node

var haptic_enabled = true

################
# ACHIEVEMENTS #
################

################
# LEADERBOARD  #
################

################
#   FIREBASE   #
################

################
#    ADMOB     #
################



# void start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0)
# Joypads usually come with two rumble motors, a strong and a weak one.
# weak_magnitude is the strength of the weak motor (between 0 and 1)
# and strong_magnitude is the strength of the strong motor (between 0 and 1).
# duration is the duration of the effect in seconds (a duration of 0 will try to play the vibration indefinitely).
# Note: Not every hardware is compatible with long effect durations; it is
# recommended to restart an effect if it has to be played for more than a few seconds.

func perform_haptic_feedback(constant:int) -> void:
	if haptic_enabled:
		if constant == C.tap_vibration:
			Input.start_joy_vibration(0, 0.1, 0.1, 0.1)
		elif constant == C.soft_vibration:
			Input.start_joy_vibration(0, 0.1, 0.1, 0.1)
		elif constant == C.fail_vibration:
			Input.start_joy_vibration(0, 0.1, 0.4, 0.4)
		elif constant == C.success_vibration:
			Input.start_joy_vibration(0, 0.1, 0.2, 0.2)

