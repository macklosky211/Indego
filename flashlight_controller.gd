extends SpotLight3D
class_name flashlight_controller

const MAX_CHARGE = 160.0

var is_flashlight_on : bool = false
var battery : float = MAX_CHARGE

func _ready() -> void:
	if not is_multiplayer_authority(): set_physics_process(false)

func _physics_process(delta : float):
	if Input.is_action_just_pressed("Flashlight"): _try_toggle_flashlight()
	if is_flashlight_on: battery = clampf(battery - delta, 0.0, INF)
	else: battery = clampf(battery + (delta * 2), 0.0, MAX_CHARGE)

func _try_toggle_flashlight() -> void:
	if battery > 0: is_flashlight_on = not is_flashlight_on
	else: is_flashlight_on = false
	
	set_flashlight.rpc(is_flashlight_on)

@rpc("any_peer", "call_local")
func set_flashlight(value : bool) -> void:
	self.visible = value