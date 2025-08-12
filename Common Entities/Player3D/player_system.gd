class_name Player extends CharacterBody3D

@onready var vault_system: VaultSystem = $VaultSystem

## Setting this value in the editor allows us to specify the default state that the player is in.
@export var current_state : PlayerState = null:
	set(val):
		if current_state is PlayerState: current_state.call("exit", self)
		current_state = val
		if current_state is PlayerState: current_state.call("enter", self)

var states : Dictionary[StringName, PlayerState]

func _ready() -> void:
	initialize_states()
	Event.player_events.changed_perspective.connect(toggle_player_outline)

func _physics_process(delta: float) -> void:
	if current_state is PlayerState: current_state.call("physics_update", self, delta)
	if not is_on_floor(): velocity += get_gravity() * delta
	move_and_slide()

## Initializes the states dictionary with all state nodes connected to the playerStates Node.
func initialize_states() -> void:
	for child : PlayerState in $PlayerStates.get_children():
		states[child.name] = child

func toggle_player_outline(val : CameraController.CAMERA_TYPE) -> void:
	var material : Material = load("res://Assets/Shaders/basic_outline_overlay.tres")
	var mesh : MeshInstance3D = $PlayerMesh
	if val == CameraController.CAMERA_TYPE.FIRST_PERSON:
		mesh.material_overlay = null
	else:
		mesh.material_overlay = material
