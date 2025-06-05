extends Camera3D
const camera_sensitivity = 0.001
@onready var player: Player_Controller = $".."

var mouse_lock = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Menu_Button"): _Lock_Mouse(not mouse_lock)
	
func _Lock_Mouse(val : bool) -> void:
	mouse_lock = val
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if val else Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.rotation.y -= event.relative.x * camera_sensitivity
		rotation.x = clampf(rotation.x - event.relative.y * camera_sensitivity, -1.8, 1.8)
	elif event is InputEventMouseButton:
		if event.button_index == 1:
			if not mouse_lock:
				_Lock_Mouse(true)
