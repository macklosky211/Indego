extends Interactable

func _interact(_Character : Player_Controller) -> void:
	%Director._change_monster_area()
