extends Creature_State
class_name Creature_Idle

func _update(_creature : Creature_Controller, _delta : float) -> void:
	pass

func _get_state_name() -> String:
	return "Creature_Idle"
