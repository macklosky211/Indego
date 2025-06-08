extends Creature_State
class_name Creature_Alert

@onready var vision: Creature_Vision = $"../../Vision"

const  CREATURE_SPEED: float = 5
const  ACCEL: float = 1

func _update(creature : Creature_Controller, _delta : float) -> void:
	creature.creature_state = creature.Idle_In_Area

func _get_state_name() -> String:
	return "Creature_Chasing"
