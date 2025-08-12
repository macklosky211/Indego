extends Node
class_name Interactable

signal interacting(Character : Player_Controller)


func _interact(Character : Player_Controller) -> void:
	interacting.emit(Character)
