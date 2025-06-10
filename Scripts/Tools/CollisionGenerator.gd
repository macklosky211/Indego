@tool
extends Node3D
class_name Collision_Generator

@export_tool_button("Generate Collsion Shapes") var generate_collsion_boxes_button = boxes

func boxes() -> void:
	print("Generating Collision Meshes")
	for child in get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
	print("Done generating Collsion Meshes")
