class_name VaultSystem extends Node

@onready var player : Player = self.find_parent("Player")

@onready var vertical_check: RayCast3D = $VerticalCheck
@onready var low_check: ShapeCast3D = $LowCheck
@onready var high_check: ShapeCast3D = $HighCheck

func can_vault() -> bool: return low_check.is_colliding() and not high_check.is_colliding()

func vault_destination() -> Vector3:
	vertical_check.global_position = Vector3(0.0, 1.0, 0.0) + low_check.get_collision_point(0)
	vertical_check.force_update_transform()
	vertical_check.force_raycast_update()
	if vertical_check.is_colliding():
		return vertical_check.get_collision_point()
	else:
		return Vector3.ZERO
