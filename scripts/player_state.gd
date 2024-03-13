# player_state.gd

# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name PlayerState
extends State

# Typed reference to the player node.
var cockroach: KinematicCockroach
var collision_shape: CollisionShape2D


func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	yield(get_parent().get_parent(), "ready")
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	cockroach = get_parent().get_parent() as KinematicCockroach
	collision_shape = cockroach.get_node("CollisionShape2D") as CollisionShape2D
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(cockroach != null)
