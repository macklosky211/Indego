extends Player_State
class_name Player_Idle

func _update(player : Player_Controller, _delta : float) -> void:
	if _get_input(): player.current_state = player.Grounded_Movement

func _get_state_name() -> String:
	return "Player_Idle"
