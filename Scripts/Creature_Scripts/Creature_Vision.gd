extends Node
class_name Creature_Vision

@onready var mid_vision: Area3D = $Mid_Vision
@onready var vision_cast : RayCast3D = $RayCast3D

func _Check_Vision(area : Area3D) -> Array[Player_Controller]:
	var Players_In_Vision : Array[Player_Controller]
	for object in area.get_overlapping_bodies():
		if object is Player_Controller:
			vision_cast.target_position = (object.global_position - vision_cast.global_position)
			vision_cast.global_rotation = Vector3.ZERO
			vision_cast.force_raycast_update()
			if vision_cast.get_collider() is Player_Controller: Players_In_Vision.append(object)
	return Players_In_Vision

func _Check_All_Vision() -> Array[Player_Controller]:
	var Players_In_Vision : Array[Player_Controller]
	for player in _Check_Vision(mid_vision):
		if player not in Players_In_Vision : Players_In_Vision.append(player)
	#add other visions here :)
	return Players_In_Vision

func _check_med_vision() -> Array[Player_Controller]:
	return _Check_Vision(mid_vision)

func _check_low_vision() -> Array[Player_Controller]:
	return []

func _check_high_vision() -> Array[Player_Controller]:
	return []
