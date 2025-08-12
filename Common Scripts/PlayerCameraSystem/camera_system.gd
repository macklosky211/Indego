class_name CameraController extends Camera3D

enum CAMERA_TYPE {FIRST_PERSON, THIRD_PERSON}

@export var camera_type : CAMERA_TYPE = CAMERA_TYPE.FIRST_PERSON

@onready var third_person_position: Marker3D = $Third_Person_Position
@onready var first_person_position: Marker3D = $First_Person_Position

@export var input_enabled : bool = true:
	set(val):
		set_process_unhandled_input(val)
		set_process_input(val)
		input_enabled = val

@onready var parent : Node3D = self.get_parent()
@export var rotate_parent : bool = true:
	set(val):
		if val: parent = self.get_parent()
		rotate_parent = val

@export var can_change_perspective : bool = false
@export var default_fov : float = 75.0:
	set(val):
		self.fov = val
		default_fov = val

@export var seperate_axis_sensitivities : bool = false
@export var v_camera_sensitivty : float = 0.01
@export var h_camera_sensitivty : float = 0.01

@export var follow_parent : bool = true:
	set(val):
		set_process(val)
		follow_parent = val

@export var follow_target : Node3D = null
var follow_position : Vector3 = Vector3.ZERO
@export var follow_strength : float = 5.0

## Max vertical looking angle (Stops 360* spinning camera)
@export var min_angle : float = -90.0
@export var max_angle : float = 90.0

@export var zooming_enabled : bool = false
@export var zoom_max : float = 150.0
@export var zoom_min : float = default_fov
@export var zoom_sensitivity : float = 5.0

var camera_offset_from_player : Vector3 = Vector3.ZERO

func _init() -> void:
	assert(ProjectSettings.has_setting("Mouse_Settings/Horizontal_Sensitivity"), "Project does not have proper settings set up.")
	assert(ProjectSettings.has_setting("Mouse_Settings/Vertical_Sensitivity"), "Project does not have proper settings set up.")
	assert(ProjectSettings.has_setting("Mouse_Settings/Seperate_Axis_Sensitivity"), "Project does not have proper settings set up.")
	seperate_axis_sensitivities = ProjectSettings.get_setting("Mouse_Settings/Seperate_Axis_Sensitivity")
	v_camera_sensitivty = ProjectSettings.get_setting("Mouse_Settings/Vertical_Sensitivity")
	h_camera_sensitivty = ProjectSettings.get_setting("Mouse_Settings/Horizontal_Sensitivity")

func _ready() -> void:
	if camera_type == CAMERA_TYPE.THIRD_PERSON: 
		camera_type = CAMERA_TYPE.FIRST_PERSON # Change_Perspective will flip the camera type.
		change_perspective()

func _process(delta: float) -> void:
	if not follow_parent:
		if follow_target: global_position = global_position.move_toward(follow_target.global_position, delta)
		else: global_position = global_position.move_toward(follow_position, delta)
	
	if Input.is_action_just_pressed("Escape"):
		CommonFunctions.lock_mouse(not CommonFunctions.is_mouse_locked())
	if not CommonFunctions.is_mouse_locked() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		CommonFunctions.lock_mouse(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		## Vertical
		rotate(Vector3.LEFT, event.relative.y * h_camera_sensitivty)
		rotation_degrees.x = clampf(rotation_degrees.x, min_angle, max_angle)
		
		## Horizontal
		if rotate_parent: parent.rotate(Vector3.UP, -event.relative.x * v_camera_sensitivty)
		else: rotate(Vector3.UP, -event.relative.x * v_camera_sensitivty)
		
		if camera_type == CAMERA_TYPE.THIRD_PERSON:
			var y : float = camera_offset_from_player.z * sin(rotation.x)
			position = camera_offset_from_player + Vector3(0.0, -y, 0.0)
	
	if zooming_enabled:
		var zoom_axis : float = Input.get_axis("Zoom Out", "Zoom In")
		if zoom_axis != 0.0:
			change_fov(fov - (zoom_axis * zoom_sensitivity), 0.1)
	
	if can_change_perspective and Input.is_action_just_pressed("Change Camera View"): change_perspective()

var is_changing_fov : bool = false
signal fov_block_signal()

func change_fov(target_fov : float, time_to_change : float) -> void:
	if target_fov > 179 or target_fov < 1: return
	if is_changing_fov:
		is_changing_fov = false
		await fov_block_signal
	is_changing_fov = true
	var time_interval : float = time_to_change / 50.0
	for i : int in range(0, 50, 1):
		var t : float = float(i) / 50.0
		if not is_changing_fov:fov_block_signal.emit(); return
		fov = lerpf(fov, target_fov, t)
		await get_tree().create_timer(time_interval).timeout
	is_changing_fov = false
	fov_block_signal.emit()

func change_perspective() -> void:
	assert(camera_type != null, "Camera_Type was null.")
	var destination : Vector3
	
	match camera_type:
		CAMERA_TYPE.FIRST_PERSON:
			camera_type = CAMERA_TYPE.THIRD_PERSON
			destination = third_person_position.position
			camera_offset_from_player = destination
		CAMERA_TYPE.THIRD_PERSON:
			camera_type = CAMERA_TYPE.FIRST_PERSON
			destination = first_person_position.position
	
	Event.player_events.changed_perspective.emit(camera_type)
	
	for i : int in range(0, 10, 1):
		var t : float = float(i) / 10.0
		position.x = lerpf(position.x, destination.x, t)
		position.y = lerpf(position.y, destination.y, t)
		position.z = lerpf(position.z, destination.z, t)
		await get_tree().create_timer(0.005).timeout
