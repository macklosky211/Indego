extends Player_State
class_name Player_Air_Movement

func _update(player : Player_Controller, _delta : float) -> void:
	if player.is_on_floor(): player.current_state = player.Idle

func _get_state_name() -> String:
	return "Player_Air_Movement"
