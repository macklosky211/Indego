extends Player_State
class_name Player_Air_Movement

func _enter(player : Player_Controller) -> void:
	player.current_state = player.Idle
