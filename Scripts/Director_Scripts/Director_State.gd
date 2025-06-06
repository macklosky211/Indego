extends Node
class_name Director_State

func _enter(_Creature : Director) -> void:
	pass

func _exit(_Creature : Director) -> void:
	pass
	
func _update(_Creature : Director) -> void:
	pass

func _get_state_name() -> String:
	return "Director_Template_State"

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
