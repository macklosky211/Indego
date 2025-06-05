extends Node
class_name Creature_Vision

@onready var mid_vision: Area3D = $Mid_Vision
func _Check_Vision(area : Area3D) -> Array[Player_Controller]:
	var Players_In_Vision : Array[Player_Controller]
	for object in area.get_overlapping_bodies():
		if object is Player_Controller:
			Players_In_Vision.append(object)
	return Players_In_Vision

func _Check_All_Vision() -> Array[Player_Controller]:
	var Players_In_Vision : Array[Player_Controller]
	for player in _Check_Vision(mid_vision):
		if player not in Players_In_Vision : Players_In_Vision.append(player)
	#add other visions here :)
	return Players_In_Vision
