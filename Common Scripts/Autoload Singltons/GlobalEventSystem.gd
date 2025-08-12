class_name EventSystem extends Node

var global_events : global_events_class = global_events_class.new()
var player_events : player_events_class = player_events_class.new()

class global_events_class:
	signal lock_mouse(val : bool)

class player_events_class:
	signal changed_perspective(new_perspective : CameraController.CAMERA_TYPE)
