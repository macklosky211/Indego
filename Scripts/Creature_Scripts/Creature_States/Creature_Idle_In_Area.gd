extends Creature_State
class_name Creature_Idle_In_Area

const CREATURE_SPEED : float = 5.0

var interacted_with_last_POI : bool = false

func _update(creature : Creature_Controller, _delta : float) -> void:
	# if vision._Check_All_Vision().size() > 0: print("0_0")
	_handle_vision()

	if creature.Nav_Agent.is_target_reached(): _interact_with_POI()

	if interacted_with_last_POI: creature.Nav_Agent.target_position = Vector3.ZERO 

	if creature.Nav_Agent.target_position == Vector3.ZERO: 
		creature.Nav_Agent.target_position = _find_something_to_do_in_area()
	if not creature.Nav_Agent.is_target_reachable(): target_idle_spot = Vector3.ZERO; push_error("Couldnt reach idle_interaction_spot"); return

	var direction : Vector3 = (creature.Nav_Agent.get_next_path_position() - creature.global_position).normalized() * CREATURE_SPEED

	creature.velocity = direction
	creature.target_to_look_at = direction # This wont work. we should be overwriting the AI's rotation directly here. _enter/exit needs to set should_look_at_target = true/false

@onready var vision: Creature_Vision = $"../../Vision"

func _get_state_name() -> String:
	return "Creature_Idle_In_Area"

func _handle_vision() -> void:
	var low_visible_players  : Array[Player_Controller] = vision._check_low_vision()
	var med_visible_players  : Array[Player_Controller] = vision._check_med_vision()
	var high_visible_players : Array[Player_Controller] = vision._check_high_vision()
	if high_visible_players.size() > 0:
		print("I can see you from REALLY far away.")
		return
	elif med_visible_players.size() > 0:
		print("I can see you well, but im not looking directly at you yet.")
		return
	elif low_visible_players.size() > 0:
		print("I can barely see you, I should start a timer before I notice you and go on alert.")
		return

func _find_something_to_do_in_area(creature: Creature_Controller) -> Vector3:
	var idle_spots : Array[Node3D] = creature.current_area.get_idle_interaction_spots()
	var random_selection : Vector3 = idle_spots[randi_in_range(0, idle_spots.size() - 1)].global_position
	return random_selection

func _interact_with_POI() -> void:
	# We should play the idle interaction animation here, and when that finishes THEN set this flag to true.
	interacted_with_last_POI = true