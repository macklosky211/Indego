extends Player_State
class_name Player_Idle

const DECEL = 1.0

func _update(player : Player_Controller, _delta : float) -> void:
	if _get_input(): player.current_state = player.Grounded_Movement; return
	else: player.velocity = _move_vector_towards2(player.velocity, Vector3.ZERO, DECEL)

func _get_state_name() -> String:
	return "Player_Idle"
