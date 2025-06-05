extends Creature_State
class_name Creature_Idle_In_Area

func _update(_creature : Creature_Controller, _delta : float) -> void:
	# if vision._Check_All_Vision().size() > 0: print("0_0")
	_handle_vision()

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