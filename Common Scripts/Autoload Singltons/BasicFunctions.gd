class_name BasicFunctions extends Node

func _ready() -> void:
	Event.global_events.lock_mouse.connect(lock_mouse)

## Returns if the users mouse is locked or not.
func is_mouse_locked() -> bool : return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

## based on inputted value it captures the users mouse.
func lock_mouse(val : bool = true) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if val else Input.MOUSE_MODE_VISIBLE
