extends Creature_State
class_name Creature_Chasing

@onready var vision: Creature_Vision = $"../../Vision"

var target: Player_Controller
const  CREATURE_SPEED: float = 5
const  ACCEL: float = 1

func _update(creature : Creature_Controller, _delta : float) -> void:
	creature.Nav_Agent.target_position = target.nav_Point + (target.velocity.normalized() * (creature.global_position.distance_to(target.global_position)))
	var next_path_postion : Vector3 = creature.Nav_Agent.get_next_path_position()
	var target_Velocity : Vector3 = (next_path_postion - creature.global_position).normalized() * CREATURE_SPEED
	creature.velocity = _move_vector_towards2(creature.velocity, target_Velocity, ACCEL)
	creature.target_to_look_at = target.global_position
	var players = vision._Find_Closest_Player()
	if players.size() == 0 : creature.creature_state = creature.Alert; return
	target = players[0]

func _get_state_name() -> String:
	return "Creature_Chasing"
