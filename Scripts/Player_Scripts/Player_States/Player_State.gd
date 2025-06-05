extends Node
class_name Player_State

func _enter(_Player : Player_Controller) -> void:
	pass

func _exit(_Player : Player_Controller) -> void:
	pass
	
func _update(_Player : Player_Controller, _delta : float) -> void:
	pass

func _get_state_name() -> String:
	return "Player_Template_State"

func _get_input() -> Vector2:
	return Input.get_vector("Left", "Right", "Down", "Up")

func _move_vector_towards(original_value : Vector3, desired_value : Vector3, delta : float) -> Vector3:
	var result = Vector3.ZERO
	result.x = move_toward(original_value.x, desired_value.x, delta)
	result.y = move_toward(original_value.y, desired_value.y, delta)
	result.z = move_toward(original_value.z, desired_value.z, delta)
	return result

func _move_vector_towards2(original_value : Vector3, desired_value : Vector3, delta : float) -> Vector3:
	var result = original_value
	result.x = move_toward(original_value.x, desired_value.x, delta)
	result.z = move_toward(original_value.z, desired_value.z, delta)
	return result
