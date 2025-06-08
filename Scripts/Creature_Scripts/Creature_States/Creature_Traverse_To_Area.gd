extends Creature_State
class_name Traverse_To_Area

const CREATURE_SPEED : float = 5.0
var destination : Vector3

func _update(creature : Creature_Controller, _delta : float) -> void:
	if not creature.Nav_Agent.is_target_reachable(): creature.Nav_Agent.target_position = Vector3.ZERO; push_error("Director lied to me :("); return
	
	var next_path_postion : Vector3 = creature.Nav_Agent.get_next_path_position()
	
	var direction : Vector3 = (next_path_postion - creature.global_position).normalized() * CREATURE_SPEED
	
	creature.velocity = direction
	creature.target_to_look_at = next_path_postion
	if(creature.Nav_Agent.navigation_finished): creature.creature_state = creature.Idle_In_Area; return
	
func _enter(creature : Creature_Controller) -> void:
	creature.Nav_Agent.target_position = destination 

func _get_state_name() -> String:
	return "Creature_Traverse_To_Area"
