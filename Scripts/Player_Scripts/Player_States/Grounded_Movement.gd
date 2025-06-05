extends Player_State
class_name Player_Grounded_Movement

const speed = 5.0
const accel = 1

func _update(player : Player_Controller, _delta : float) -> void:
	var input : Vector2 = _get_input()
	var direction : Vector3 = player._get_world_direction_from_input(input)
	direction *= speed
	direction.y = 0
	player.velocity = _move_vector_towards2(player.velocity, direction, accel)
	if player.velocity.x == 0 and player.velocity.z == 0: player.current_state = player.Idle
	
func _get_state_name() -> String:
	return "Player_Moving"
