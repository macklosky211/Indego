extends CharacterBody3D
class_name Player_Controller

@onready var ray_cast: RayCast3D = $Camera3D/RayCast3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var ground_detection: RayCast3D = $GroundDetection

var nav_Point : Vector3:
	get():
		if ground_detection.is_colliding(): nav_Point = ground_detection.get_collision_point()
		else:
			nav_Point = global_position
		return nav_Point
		
var current_area : Map_Area:
	set(value):
		if value is Object: print("[", self.name, "] entered new zone: ", value.name)
		current_area = value

var is_gravity : bool = true
var is_stunned : bool = false
var is_flashlight_on : bool = false

var current_state: Player_State:
	set(value):
		if current_state is Object and current_state.has_method("_exit"): current_state._exit(self)
		current_state = value
		print(current_state._get_state_name())
		if current_state is Object and current_state.has_method("_enter"): current_state._enter(self)


@onready var Idle: Player_State = $Idle
@onready var Grounded_Movement: Player_State = $Grounded_Movement
@onready var Air_Movement: Player_Air_Movement = $Air_Movement

func _ready() -> void:
	flashlight.visible = is_flashlight_on
	if not is_multiplayer_authority(): set_process(false); set_physics_process(false); return
	current_state = Idle

func _physics_process(delta: float) -> void:
	if current_state is Object and current_state.has_method("_update"): current_state._update(self, delta)
	if is_gravity : velocity += get_gravity() * delta
	move_and_slide()
	
	if not is_stunned: _handle_interaction()

func _get_world_direction_from_input(local_vector : Vector2) -> Vector3:
	return (transform.basis * Vector3(local_vector.x, 0, -local_vector.y)).normalized()

func _handle_interaction() -> void:
	if Input.is_action_just_pressed("Interact"):
		var target = ray_cast.get_collider()
		if target is Interactable: target._interact(self)
	elif Input.is_action_just_pressed("Flashlight"):
		_toggle_flashlight.rpc()

@rpc("any_peer", "call_local")
func _toggle_flashlight() -> void:
	is_flashlight_on = not is_flashlight_on
	flashlight.visible = is_flashlight_on
