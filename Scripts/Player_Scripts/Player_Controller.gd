extends CharacterBody3D
class_name Player_Controller

var is_gravity = true

var current_state: Player_State:
	set(value):
		if current_state is Object and current_state.has_method("_exit"): current_state._exit(self)
		current_state = value
		print(current_state._get_state_name())
		if current_state is Object and current_state.has_method("_enter"): current_state._enter(self)

@onready var Idle: Player_State = $Idle
@onready var Grounded_Movement: Player_State = $Grounded_Movement

func _ready() -> void:
	current_state = Idle

func _physics_process(delta: float) -> void:
	if current_state is Object and current_state.has_method("_update"): current_state._update(self, delta)
	if is_gravity : velocity += get_gravity()*delta
	move_and_slide()

func _get_world_direction_from_input(local_vector : Vector2) -> Vector3:
	return (transform.basis * Vector3(local_vector.x, 0, -local_vector.y)).normalized()
