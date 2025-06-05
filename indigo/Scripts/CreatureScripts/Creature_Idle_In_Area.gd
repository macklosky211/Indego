extends Creature_State
class_name Creature_Idle_In_Area

func _update(_creature : Creature_Controller, _delta : float) -> void:
	if vision._Check_All_Vision().size() > 0: print("0_0")
	
@onready var vision: Creature_Vision = $"../../Vision"

func _get_state_name() -> String:
	return "Creature_Idle_In_Area"
