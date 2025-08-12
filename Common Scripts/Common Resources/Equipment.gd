extends Node
class_name Equipment

var equipment_name : String = "null"

func pickup(target_inventory : Inventory) -> void:
	target_inventory.add_item_to_inventory(self)

func drop() -> void:
	print("You tried dropping ", equipment_name)

func use_equipment(_player : Player_Controller) -> void:
	print("You tried using ", equipment_name)

func _to_string() -> String:
	return equipment_name
