extends Player_State
class_name Player_Grounded_Movement

const FORWARD_WALK_SPEED : float = 5.0
const BACKWARD_WALK_SPEED : float = FORWARD_WALK_SPEED * 0.5
const STRAFE_WALK_SPEED : float = FORWARD_WALK_SPEED * 0.75
const DIAGNAL_WALK_SPEED : float = (FORWARD_WALK_SPEED + STRAFE_WALK_SPEED)  * 0.5

const FORWARD_SPRINT_SPEED : float = 10.0
const BACKWARD_SPRINT_SPEED : float = FORWARD_SPRINT_SPEED * 0.5
const STRAFE_SPRINT_SPEED : float = FORWARD_SPRINT_SPEED * 0.75
const DIAGNAL_SPRINT_SPEED : float = (FORWARD_SPRINT_SPEED + STRAFE_SPRINT_SPEED)  * 0.5

const FORWARD_CROUCH_SPEED : float = 2.5
const BACKWARD_CROUCH_SPEED : float = FORWARD_CROUCH_SPEED * 0.5
const STRAFE_CROUCH_SPEED : float = FORWARD_CROUCH_SPEED * 0.75
const DIAGNAL_CROUCH_SPEED : float = (FORWARD_CROUCH_SPEED + STRAFE_CROUCH_SPEED)  * 0.5

const WALK_SPEEDS   : Array[float] = [0, FORWARD_WALK_SPEED,   BACKWARD_WALK_SPEED,   STRAFE_WALK_SPEED,   DIAGNAL_WALK_SPEED  ]
const SPRINT_SPEEDS : Array[float] = [0, FORWARD_SPRINT_SPEED, BACKWARD_SPRINT_SPEED, STRAFE_SPRINT_SPEED, DIAGNAL_SPRINT_SPEED]
const CROUCH_SPEEDS : Array[float] = [0, FORWARD_CROUCH_SPEED, BACKWARD_CROUCH_SPEED, STRAFE_CROUCH_SPEED, DIAGNAL_CROUCH_SPEED]

const ACCEL : float = 1.0

func _update(player : Player_Controller, _delta : float) -> void:
	if not player.is_on_floor(): player.current_state = player.Air_Movement; return
	var input : Vector2 = _get_input()

	var speed_array : Array[float] = WALK_SPEEDS
	var speed_index = 0 # Default to '0' AKA no speed.
	if input.x != 0: # If were holding left/right we are either strafing or moving diagnal.
		speed_index = 3 # STRAFE_SPEED
		speed_index += absf(input.y) # Move towards Diagnal
	elif: input.y > 0: speed_index = 1 # If not strafing were either going forwards 
	elif: input.y < 0: speed_index = 2 # or backwards.

	if Input.is_action_pressed("Crouch_Modifier"): speed_array = CROUCH_SPEEDS
	elif Input.is_action_pressed("Sprint_Modifier"): speed_array = SPRINT_SPEEDS
	
	var direction : Vector3 = player._get_world_direction_from_input(input) * speed_array[speed_index]
	player.velocity = _move_vector_towards2(player.velocity, direction, ACCEL)
	if player.velocity.x == 0 and player.velocity.z == 0: player.current_state = player.Idle
	
func _get_state_name() -> String:
	return "Player_Moving"
